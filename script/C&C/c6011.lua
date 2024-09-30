--C&C Callsign 00, Start Cleaning!
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned properly
    c:EnableReviveLimit()
    --Special Summon Neru once per turn
    c:SetSPSummonOnce(id)
    --Link summon
    Link.AddProcedure(c,s.lsmats,1,1)
    --Inflict damage
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetRange(LOCATION_MZONE)
    e1:SetCost(s.idcost)
    e1:SetCondition(s.idcon)
    e1:SetTarget(s.idtg)
    e1:SetOperation(s.idop)
    c:RegisterEffect(e1)
    --Special Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER_E)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_series={0x258}
function s.idcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
--Non-link C&C monsters
function s.lsmats(c,scard,sumtype,tp)
    return c:IsSetCard(0x258,scard,sumtype,tp) and not c:IsType(TYPE_LINK,scard,sumtype,tp)
end
--Checks if properly summoned
function s.idcon(e)
    local c=e:GetHandler()
    return c:IsSummonType(TYPE_LINK)
end
function s.filtg(c,e)
    return c:IsCanBeEffectTarget(e) and c:IsMonster()
end
function s.idtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.filtg(chkc,e) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(s.filtg,tp,0,LOCATION_MZONE,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.filtg,tp,0,LOCATION_MZONE,1,1,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,g,#g,1-tp,0)
end
function s.idop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetTargetCards(e):GetFirst()
    if not tc:IsRelateToEffect(e) then return end
    Duel.Damage(1-tp,math.ceil((tc:GetAttack())/2),REASON_EFFECT)
    if e:GetHandler():GetMaterial():FilterCount(Card.IsCode,nil,6000)>0 then
        Duel.BreakEffect()
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
function s.spcon()
    return Duel.IsMainPhase()
end
function s.spfil(c,e,tp)
    return c:IsSetCard(0x258) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
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