--Hinoko, The Mystique
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Place 1 "Sigil" Spell/Trap from GY to SZONE
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
    --Send 1 Spell to GY or target and destroy a monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.xdcost)
    e3:SetTarget(s.xdt)
    e3:SetOperation(s.xdop)
    c:RegisterEffect(e3)
end
s.listed_series={0x28a}
function s.plfil(c,e)
    return c:IsSetCard(0x28c)
end
function s.plt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return
    Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.plfil),tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
    local lc=Duel.GetLocationCount(tp,LOCATION_SZONE)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.plfil),tp,LOCATION_GRAVE,0,nil)
    if #g<1 or lc<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
end
function s.costfil(c)
    return c:IsSetCard(0x28c) and c:IsAbleToGraveAsCost()
end
--Sends up to 2 spell/trap to the GY
function s.xdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ct=0
        if not (Duel.IsPlayerCanSendtoGrave(tp)
        and Duel.IsExistingMatchingCard(s.costfil,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.xdfil,tp,LOCATION_DECK,0,1,nil))
        then return false else ct=ct+1 end
        if Duel.IsExistingTarget(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,e:GetHandler())
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
function s.xdfil(c,e)
    return c:IsAbleToGrave() and (c:IsSetCard(0x28a) or c:IsSetCard(0x28c))
end
function s.xdt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local ct=e:GetLabel()
    if ct>=1 then
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK) end
    if ct>=2 then
    e:SetProperty(EFFECT_FLAG_CARD_TARGET)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE) end
end
function s.xdop(e,tp,eg,ep,ev,re,r,rp)
    local lb=e:GetLabel()
    local g=Duel.GetMatchingGroup(s.xdfil,tp,LOCATION_DECK,0,nil)
    --Send 1 "Mystique" card or 1 "Sigil" Spell/Trap
    if lb>=1 and #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local sc=g:Select(tp,1,1,nil)
        Duel.SendtoGrave(sc,REASON_EFFECT)
    end
    --Target and destroy
    if lb>=2
    and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,e:GetHandler()) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sc=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,1,1,e:GetHandler())
        Duel.Destroy(sc,REASON_EFFECT)
    end
end
