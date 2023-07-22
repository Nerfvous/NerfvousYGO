--Sigil of Knowledge
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --"Mystique" monsters cannot be targeted
	local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(aux.FaceupFilter(Card.IsSetCard,0x28a)))
    e2:SetValue(s.stval)
    c:RegisterEffect(e2)
    --Draw 1 card
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,0})
    e3:SetTarget(s.drawt)
    e3:SetOperation(s.drawop)
    c:RegisterEffect(e3)
    --Add and special summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(s.ahcon)
    e4:SetTarget(s.aht)
    e4:SetOperation(s.ahop)
    c:RegisterEffect(e4)
end
s.listed_series={0x28c}
function s.stval(e,re,rp,tp)
    return aux.tgoval(e,re:IsActiveType(TYPE_SPELL+TYPE_TRAP),rp)
end
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsPlayerCanDraw(tp)
    and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,2,nil)
    and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
function s.drawt(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
    and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,2,nil) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.ahcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
end
function s.ahfil(c,e)
    return c:IsMonster() and c:IsLevelBelow(4)
    and c:IsRace(RACE_SPELLCASTER) and c:IsFaceup()
end
function s.aht(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE)
    and chkc:IsAbleToHand() and s.ahfil(chkc,e) end
    if chk==0 then return Duel.IsPlayerCanSendtoHand(tp)
    and Duel.IsExistingTarget(aux.NecroValleyFilter(s.ahfil,e),tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sc=Duel.SelectTarget(tp,aux.NecroValleyFilter(s.ahfil,e),tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,sc,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sc,1,0,0)
end
function s.ahop(e,tp,eg,ep,ev,re,r,rp)
    local sc=Duel.GetTargetCards(e):GetFirst()
    if sc and Duel.SendtoHand(sc,tp,REASON_EFFECT)>0
    and sc:IsSetCard(0x28a)
    and Duel.IsPlayerCanSpecialSummon(tp)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.SpecialSummonStep(sc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP_DEFENSE)
        --Negate its effect
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e1,true)
        local e2=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE_EFFECT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e1,true)
        Duel.SpecialSummonComplete()
    end
end