--Fae Thoir Alr Falbh
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Destroy s/t
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
end
s.listed_series={0x29e}
--filter
function s.filter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
--Activation check
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsType() end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
    local n=0
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,6704),tp,LOCATION_MZONE,0,1,nil) then
        n=2
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1+n,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
--Operation
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg>0 then
        Duel.Destroy(tg,REASON_EFFECT)
    end
end