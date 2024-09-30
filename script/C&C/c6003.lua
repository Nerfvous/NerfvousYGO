--C&C 03: Akane
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Special summon 1 Link monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.spsumtg1)
    e1:SetOperation(s.spsumop1)
    c:RegisterEffect(e1)
    --Checks if Akane was special summon in a zone pointed by a link card
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.regcon)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
    --Add 1 "C&C" card in your GY to your hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end
s.listed_series={0x258}
--Checks if opp's turn and is main phase
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==1-tp and Duel.IsMainPhase()
end
function s.lsfilter(c,e)
    return c:IsSetCard(0x258) and c:IsLinkSummonable(e:GetHandler())
end
--Checks if there are any link monsters that can be Link Summon
function s.spsumtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lsfilter,tp,LOCATION_EXTRA,0,1,nil,e) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
--Link summon operation
function s.spsumop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsControler(1-tp) then return end
    local g=Duel.GetMatchingGroup(s.lsfilter,tp,LOCATION_EXTRA,0,nil,e)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.LinkSummon(tp,sg:GetFirst(),c)
    end
end
function s.lkfilter(c,oc)
    return c:GetLinkedGroup():IsContains(oc) and c:IsRace(RACE_WARRIOR)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.thfilter(c)
    return c:IsSetCard(0x258) and c:IsAbleToHand()
end
--Checks for C&C card in GY
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return c:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
    if chk==0 then return Duel.GetMatchingGroupCount(s.thfilter,tp,LOCATION_GRAVE,0,nil)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetTargetCards(e)
    if #g<1 then return end
    Duel.SendtoHand(g,tp,REASON_EFFECT)
    local g1=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
    if c:HasFlagEffect(id,1) and #g1>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
        local sc=g1:Select(tp,1,1,nil):GetFirst()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(-(math.ceil(sc:GetAttack()/2)))
        sc:RegisterEffect(e1)
    end
end