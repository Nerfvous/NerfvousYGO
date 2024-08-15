--Fae Mallachd
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Face-up Attack
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.postg)
    e1:SetOperation(s.posop)
    c:RegisterEffect(e1)
end
s.listed_series={0x29e}
--Change battle position
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsMonster() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsMonster,tp,LOCATION_MZONE,0,1,nil) end
    local n=0
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,6704) then n=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
    local g=Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1+n,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.chkcfil(c,e)
    return c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)
end
--Changing battle position
function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g<1 then return end
    local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    if opt==0 then
        Duel.ChangePosition(g,POS_FACEUP_ATTACK)
    else
        Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
    end
end