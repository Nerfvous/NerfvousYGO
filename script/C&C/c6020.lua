--C&C, we have a mission for you
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Special summon
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Cannot be destroyed
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.indestg)
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)
    --Draw when destroyed by battle or leave by effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_BATTLE_DESTROYED)
    e3:SetCountLimit(2,{id,3})
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.bdcon1)
    e3:SetTarget(s.bdtg)
    e3:SetOperation(s.bdop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.bdcon2)
    c:RegisterEffect(e4)

end
s.listed_series={0x258}
CNCMATS={[6011]=6000,[6012]=6001,[6013]=6002,[6014]=6003,[6015]=6004}
function s.filter(c,e,tp)
    if c:IsLocation(LOCATION_DECK) and not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
    return (c:IsLocation(LOCATION_DECK) or c:IsLocation(LOCATION_EXTRA)) and c:IsSetCard(0x258) and c:IsMonster()
end
--Special Summon from Deck
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp)
    if not dg or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
    local g1=dg:Clone()
    local g2=Group.CreateGroup()
    for k,v in pairs(CNCMATS) do
        if dg:IsExists(Card.IsCode,1,nil,k) and dg:IsExists(Card.IsCode,1,nil,v) then
            g2:Merge(g1:Filter(Card.IsCode,nil,k))
            g2:Merge(g1:Filter(Card.IsCode,nil,v))
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg1=g2:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_EXTRA):GetFirst()
    Duel.ConfirmCards(tp,sg1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg2=g2:Filter(Card.IsLocation,nil,LOCATION_DECK):FilterSelect(tp,Card.IsCode,1,1,nil,CNCMATS[sg1:GetCode()])
    Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
    --Cannot special summon, except warrior
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    aux.RegisterClientHint(c,EFFECT_FLAG_OATH,tp,1,0,aux.Stringid(id,1), nil)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetRace()~=RACE_WARRIOR
end
function s.indestg(e,c)
    local tp=e:GetHandlerPlayer()
    return c:IsLinkMonster() and c:IsLink(1) and c:IsControler(tp)
end
function s.indval(e,re,r,rp)
    if r&REASON_EFFECT~=0 or r&REASON_BATTLE~=0 then
        return 1
    else return 0 end
end
function s.bdfil1(c,tp,r)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(1-tp)
end
function s.bdfil2(c,tp,r)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(1-tp)
end
function s.bdcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg and eg:IsExists(s.bdfil1,1,nil,tp,r)
end
function s.bdcon2(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsSetCard(0x258) and eg:IsExists(s.bdfil2,1,nil,tp,r)
end
function s.bdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,LOCATION_DECK)
end
function s.bdop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end