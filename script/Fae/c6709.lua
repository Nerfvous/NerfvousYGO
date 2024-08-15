--Fae Teich
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Return to hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rthtg)
    e1:SetOperation(s.rthop)
    c:RegisterEffect(e1)
end
s.listed_series={0x29e}
--Activation
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsMonster()  and chkc:IsAbleToHand() and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0x29e),tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingTarget(Card.IsMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local tc=Duel.SelectTarget(tp,Card.IsMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
--Operation
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and Duel.SendtoHand(tc,tp,REASON_EFFECT) and tc:IsCode(6704)
    and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local dtc=Duel.SelectTarget(tp,Card.IsControler,tp,0,LOCATION_ONFIELD,1,1,nil,1-tp)
        Duel.Destroy(dtc,REASON_EFFECT)
    end
end