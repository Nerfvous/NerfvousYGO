--President Rio
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned properly
    c:EnableReviveLimit()
    --Special Summon Rio once per turn
    c:SetSPSummonOnce(id)
    --Link summon
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,2,s.lnmats)
    --Move
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetCondition(s.movecon)
    e1:SetTarget(s.movetg)
    e1:SetOperation(s.moveop)
    c:RegisterEffect(e1)
    --Attack twice
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_EXTRA_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.dbtg)
    e2:SetValue(1)
    c:RegisterEffect(e2)
end
s.listed_series={0x258}
function s.lnmats(g,lc,sumtype,tp)
    return g:IsExists(Card.IsLink,1,nil,1)
end
function s.movecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase() and Duel.IsTurnPlayer(1-tp)
end
function s.movetg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckAdjacent() end
end
function s.movefil(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and c:IsSetCard(0x258)
end
function s.moveop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        c:MoveAdjacent(tp)
        if c:GetPreviousSequence()~=c:GetSequence() and Duel.IsExistingMatchingCard(s.movefil,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local tc=Duel.SelectMatchingCard(tp,s.movefil,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
        end
    end
end
function s.dbtg(e,c)
    local oc=e:GetHandler()
    return c:IsLink(1) and oc:GetLinkedGroup():IsContains(c)
end