--C&C Callsign 04, The Strongest Has Arrived
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned properly
    c:EnableReviveLimit()
    --Special Summon Toki once per turn
    c:SetSPSummonOnce(id)
    --Link summon
    Link.AddProcedure(c,s.lsmats,1,1)
    --Inflict damage
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCost(s.dmgcost)
    e1:SetCondition(s.dmgcon)
    e1:SetTarget(s.dmgtg)
    e1:SetOperation(s.dmgop)
    c:RegisterEffect(e1)
    --Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_series={0x258}
--Non-link C&C monsters
function s.lsmats(c,scard,sumtype,tp)
    return c:IsSetCard(0x258,scard,sumtype,tp) and not c:IsType(TYPE_LINK,scard,sumtype,tp)
end
function s.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_EFFECT,nil)
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(TYPE_LINK)
end
function s.dmgfil(c,e)
    return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsCanBeEffectTarget(e)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_SZONE) and s.dmgfil(c,e) end
    if chk==0 then return Duel.IsExistingTarget(s.dmgfil,tp,0,LOCATION_SZONE,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,s.dmgfil,tp,0,LOCATION_SZONE,1,1,nil,e):GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,tc,1,1-tp,1000)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if Duel.Damage(1-tp,1000,REASON_EFFECT)~=0 and c:GetMaterial():FilterCount(Card.IsCode,nil,6004)>0
    and tc and tc:IsRelateToEffect(e) then
        Duel.BreakEffect()
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
function s.spfil(c,e,tp)
    return c:IsSetCard(0x258) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcon()
    return Duel.IsMainPhase()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfil(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) and e:GetHandler():IsReleasable() and
    Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.spfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetTargetCards(e)
    if #tc>0 and Duel.Release(c,REASON_COST)~=0 then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end