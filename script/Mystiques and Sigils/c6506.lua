--Registration to Mystique Academy
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Reveal and add
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.rvt)
    e1:SetOperation(s.rvop)
    c:RegisterEffect(e1)
    --Add this card to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.bncost)
    e2:SetTarget(s.bnt)
    e2:SetOperation(s.bnop)
    c:RegisterEffect(e2)
end
s.listed_series={0x28a}
function s.monfil(c)
    return c:IsRace(RACE_SPELLCASTER) and c:IsMonster() and c:IsLevel(4)
    and c:IsAbleToHand() and not c:IsForbidden()
end
function s.rvt(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.monfil,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)
    if chk==0 then return g>=4 and Duel.IsPlayerCanSendtoHand(tp) end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,4,tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg,c)
    local c1=sg:GetClassCount(Card.GetCode)
    local c2=#sg
    return c1==c2,c1~=c2
end
function s.rvop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.monfil,tp,LOCATION_DECK,0,nil)
    if g:GetClassCount(Card.GetCode)<4 or Duel.IsPlayerCanSendtoHand(tp)==false then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,1,tp,HINTMSG_ATOHAND)
    Duel.ConfirmCards(1-tp,sg)
    Duel.ShuffleDeck(tp)
    if sg:GetClassCount(Card.GetAttribute)==4 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sc=sg:Select(tp,1,1,nil)
        Duel.SendtoHand(sc,tp,REASON_EFFECT)
        Duel.ConfirmCards(tp,sc)
    else
        local sc=sg:RandomSelect(1-tp,1)
        Duel.SendtoHand(sc,tp,REASON_EFFECT)
    end
end
function s.bnfil(c,e)
    return c:IsAbleToRemoveAsCost() and c:IsSetCard(0x28c)
end
function s.bncost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanRemove(tp) and
    Duel.IsExistingMatchingCard(aux.FaceupFilter(s.bnfil),tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(s.bnfil),tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(sc,POS_FACEUP,REASON_COST)
end
function s.bnt(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
function s.bnop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        return Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end
