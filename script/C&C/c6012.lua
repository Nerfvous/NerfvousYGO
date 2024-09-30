--C&C Callsign 01, I'll Be There In The Morning!
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned properly
    c:EnableReviveLimit()
    --Special Summon Asuna once per turn
    c:SetSPSummonOnce(id)
    --Link summon
    Link.AddProcedure(c,s.lsmats,1,1)
    --Untargetable
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.utgcon)
    e1:SetTarget(s.utgtg)
    e1:SetOperation(s.utgop)
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
function s.utgcon(e)
    local c=e:GetHandler()
    return c:IsSummonType(TYPE_LINK)
end
function s.utgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsLinkMonster,tp,LOCATION_MZONE,0,1,nil) end
end
function s.utgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(Card.IsLinkMonster,tp,LOCATION_MZONE,0,nil)
    if not g then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(aux.tgoval)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsLinkMonster))
    e1:SetTargetRange(LOCATION_MZONE,0)
    Duel.RegisterEffect(e1,tp)
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