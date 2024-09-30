--C&C Callsign 03, Eliminate Those Who Disturbs Our Master
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned properly
    c:EnableReviveLimit()
    --Special Summon Akane once per turn
    c:SetSPSummonOnce(id)
    --Link summon
    Link.AddProcedure(c,s.lsmats,1,1)
    --Change to face-down
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
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
function s.posfil(c,e)
    return c:IsCanBeEffectTarget(e) and c:IsPosition(POS_FACEUP)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.posfil(chkc,e) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(s.posfil,tp,0,LOCATION_MZONE,1,nil,e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.posfil,tp,0,LOCATION_MZONE,1,1,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.posopfil(c)
    return c:IsLinkMonster() and c:IsLink(1)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0
        and c:GetMaterial():FilterCount(Card.IsCode,nil,6003) and Duel.GetMatchingGroupCount(s.posopfil,tp,LOCATION_MZONE,0,nil) then
            Duel.BreakEffect()
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetDescription(aux.Stringid(id,1))
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_DIRECT_ATTACK)
            e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
            e1:SetTargetRange(LOCATION_MZONE,0)
            e1:SetTarget(aux.TargetBoolFunction(s.posopfil))
            Duel.RegisterEffect(e1,tp)
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