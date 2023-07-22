--Mystique Academy
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Add to hand or send to GY
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.ahogt)
    c:RegisterEffect(e1)
    --Once indestructibility
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_SZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x28c))
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)
    --Shuffle up to 3 "Mystique" cards from GY/banished into the deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.sht)
    e3:SetOperation(s.shop)
    c:RegisterEffect(e3)
end
s.listed_series={0x28a}
function s.cfilter(c)
    return c:IsSetCard(0x28c)
end
function s.ahogt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil)
    and Duel.IsPlayerCanSendtoHand(tp)
    and Duel.IsPlayerCanSendtoGrave(tp) then
        e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
        e:SetOperation(s.ahogop)
        Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,1,0,0)
    else
        e:SetCategory(0)
        e:SetOperation(nil)
    end
end
function s.cfilter(c)
    return c:IsSetCard(0x28c)
end
function s.ahogop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK,0,nil)
    if #g<1 or Duel.SelectYesNo(tp,aux.Stringid(id,0))==false then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    aux.ToHandOrElse(sc,tp,
        function(c) return c:IsAbleToGrave() end,
        function(c) Duel.SendtoGrave(sc,REASON_EFFECT) end,
        aux.Stringid(id,1))
end
function s.indval(e,re,r,rp)
    if r&REASON_EFFECT~=0 then
        return 1
    else return 0 end
end
function s.shfil(c,e)
    return c:IsSetCard(0x28a) and c:IsAbleToDeck()
end
function s.sht(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.shfil(chkc) and chkc:IsCanBeEffectTarget(e) and chkc:IsFaceup()
    and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) end
    if chk==0 then return
    Duel.IsExistingMatchingCard(aux.FaceupFilter(s.shfil),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectTarget(tp,aux.FaceupFilter(s.shfil),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,tp,LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
function s.bfil(c)
    return c:IsSetCard(0x28c) and c:IsAbleToRemove() and not c:IsForbidden()
end
function s.shop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetTargetCards(e)
    if Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and #sg==3
    and Duel.IsExistingMatchingCard(s.bfil,tp,LOCATION_DECK,0,1,nil)
    and Duel.IsPlayerCanRemove(tp) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sc=Duel.SelectMatchingCard(tp,s.bfil,tp,LOCATION_DECK,0,1,1,nil)
        Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
    end
end