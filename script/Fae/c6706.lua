--Fae A'Gairm
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Special summon
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end
s.listed_series={0x29e}
--Filter
function s.filterc(c,e,tp)
    return c:IsSetCard(0x29e) and c:IsMonster() and c:IsLevel(3) and
    c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--Special summon check
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
        Duel.IsExistingMatchingCard(s.filterc,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
--Special summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local n=0
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,6704)
    and Duel.IsExistingMatchingCard(s.filterc,tp,LOCATION_DECK,0,2,nil,e)
    and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        n=1
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filterc,tp,LOCATION_DECK,0,1+n,1+n,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end