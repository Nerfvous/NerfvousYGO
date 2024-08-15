--Blanca, Loyal Servant of the Mors King
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x29e),3,2,s.xyzfilter,aux.Stringid(id,0),99)
    --Activate Quick-play Spells from hand
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_HAND,0)
    e1:SetTarget(aux.FilterBoolFunction(Card.IsSetCard,0x29e))
    c:RegisterEffect(e1)
    --Add Oberon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(aux.dxmcostgen(1,1,nil))
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
s.listed_series={0x29e}
--Filter
function s.filter(c)
    return c:IsSetCard(0x29e) and c:IsFacedown()
end
--Uses 1 facedown "Fae" monster
function s.xyzfilter(c,tp,xyzc)
    return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
--Activation check
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,6704)
        and Duel.IsPlayerCanSendtoHand(tp)
    end
end
--Operation
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,6704)
    if #g>0 then
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
        Duel.ShuffleHand(tp)
        Duel.ShuffleDeck(tp)
    end
end