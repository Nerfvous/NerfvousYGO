--Fae Cnuimh Abaich
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Flip
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
    c:RegisterEffect(e1)
end
s.listed_series={0x29e}
--Filter
function s.filtertg(c,e)
    return c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsCanChangePosition()
    and c:IsFaceup()
end
--Targetting
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filtertg(chkc,e) end
    if chk==0 then return Duel.IsExistingTarget(s.filtertg,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e) end
    local n=0
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,6704) then n=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filtertg,tp,LOCATION_MZONE,LOCATION_MZONE,1,1+n,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,tp,LOCATION_MZONE)
end
--Operation
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end