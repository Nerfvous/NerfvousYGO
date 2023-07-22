--The Tea Party Triumvirate
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
	--link summon
    Link.AddProcedure(c,aux.FilterBoolFunction(Card.IsType,TYPE_PENDULUM),2)
	c:EnableReviveLimit()
    --Add 1 revealed lvl 7 Light monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.ratht)
    e1:SetOperation(s.rathop)
    c:RegisterEffect(e1)
    --Special summon 1 level 4 or lower Light Pendulum monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_MOVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.spt)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
s.listed_series={0x294}
function s.rathfil(c)
    return c:IsLevel(7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.ratht(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.rathfil,tp,LOCATION_DECK,0,nil)
    if chk==0 then
    return g:GetClassCount(Card.GetCode)>=3
    and Duel.IsPlayerCanSendtoHand(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg1=g:Select(tp,1,1,nil)
    g:Remove(Card.IsCode,nil,sg1:GetFirst():GetCode())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg2=g:Select(tp,1,1,nil)
    g:Remove(Card.IsCode,nil,sg2:GetFirst():GetCode())
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local sg3=g:Select(tp,1,1,nil)
    sg1:Merge(sg2)
    sg1:Merge(sg3)
    Duel.ConfirmCards(1-tp,sg1)
    Duel.ShuffleHand(tp)
    Duel.SetSelectedCard(sg1)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rathop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GrabSelectedCard()
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
    local tg=sg:RandomSelect(1-tp,1)
    local tc=tg:GetFirst()
    Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
function s.spfil(c,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
    and c:IsLocation(LOCATION_PZONE) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfil,1,nil,tp)
end
function s.edfil(c)
    return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT)
    and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.spt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
    and Duel.GetLocationCount(tp,LOCATION_MZONE)>=1
    and Duel.IsExistingMatchingCard(s.edfil,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.edfil,tp,LOCATION_EXTRA,0,nil)
    if #g<1 or Duel.GetLocationCount(tp,LOCATION_MZONE)<0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
        local c=e:GetHandler()
    --Limits special summon from ED to Light Pendulum monsters
        local e1=Effect.CreateEffect(sc)
        e1:SetDescription(aux.Stringid(id,2))
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e1:SetRange(LOCATION_MZONE)
        e1:SetAbsoluteRange(tp,1,0)
        e1:SetTarget(function(_,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_LIGHT) end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e1,true)
    --Lizard check
        local e2=aux.createContinuousLizardCheck(c,LOCATION_MZONE,function(_,c) return c:IsAttribute(ATTRIBUTE_LIGHT) end)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        sc:RegisterEffect(e2,true)
    end
    Duel.SpecialSummonComplete()
end