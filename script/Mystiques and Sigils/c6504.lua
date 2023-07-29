--Tsumi, The Mystique
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
	--Place 1 "Sigil" Spell/Trap from Banish to SZONE
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCategory(CATEGORY_LEAVE_GRAVE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.plt)
    e1:SetOperation(s.plop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
    --Add 1 banished "Sigil" or target and banish a card from GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.adbcost)
    e3:SetTarget(s.adbt)
    e3:SetOperation(s.adbop)
    c:RegisterEffect(e3)
end
s.listed_series={0x28a}
function s.plfil(c,e)
    return c:IsSetCard(0x28c)
end
function s.plt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return
    Duel.IsExistingMatchingCard(s.plfil,tp,LOCATION_REMOVED,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    local lc=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local g=Duel.GetMatchingGroup(s.plfil,tp,LOCATION_REMOVED,0,nil)
    if #g<1 or lc<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end
function s.costfil(c)
    return c:IsSetCard(0x28c) and c:IsAbleToGraveAsCost()
end
--Sends up to 2 spell/trap to the GY
function s.adbcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ct=0
        if not (Duel.IsPlayerCanSendtoGrave(tp)
        and Duel.IsExistingMatchingCard(s.costfil,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(aux.FaceupFilter(s.adbfil),tp,LOCATION_REMOVED,0,1,nil))
        then return false else ct=ct+1 end
        if Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil)
        and Duel.IsPlayerCanRemove(tp)
        then ct=ct+1 end
        e:SetLabel(ct)
        return ct~=0
    end
    local ct=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfil,tp,LOCATION_HAND+LOCATION_SZONE,0,1,ct,nil)
    e:SetLabel(#g)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.adbfil(c,e)
    return c:IsAbleToHand() and (c:IsSetCard(0x28a) or c:IsSetCard(0x28c))
end
function s.adbt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local lb=e:GetLabel()
    if lb>=1 then
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED) end
    if lb>=2 then
    e:SetProperty(EFFECT_FLAG_CARD_TARGET)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE) end
end
function s.adbop(e,tp,eg,ep,ev,re,r,rp)
    local lb=e:GetLabel()
    local g=Duel.GetMatchingGroup(aux.FaceupFilter(s.adbfil),tp,LOCATION_REMOVED,0,nil)
    if lb>=1 and #g>0 then
        --Add 1 banished "Mystique"or "Sigil" to hand
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sc=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sc,tp,REASON_EFFECT)
    end
    --Target and banish
    if lb>=2
    and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sc=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,1,nil)
        Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
    end
end
