--Sigil of Fortune
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
	--Cannot activate
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.spinvul)
    c:RegisterEffect(e2)
    --Negate attack
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_CONFIRM)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,0})
    e3:SetCondition(s.atkncon)
    e3:SetTarget(s.atknt)
    e3:SetOperation(s.atknop)
    c:RegisterEffect(e3)
    --Send 3 cards to GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOGRAVE)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCountLimit(1,{id,1})
    e4:SetCondition(s.tgcon)
    e4:SetTarget(s.tgt)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)
end
s.listed_series={0x28c}
function s.spinvulfil(c,tp)
    return c:IsSetCard(0x28a) and c:IsMonster() and c:IsFaceup()
    and c:IsControler(tp)
end
function s.chainlim(e,rp,tp)
    return rp==tp or not e:IsActiveType(TYPE_MONSTER)
end
function s.spinvul(e,tp,eg,ep,ev,re,r,rp)
    if eg:IsExists(s.spinvulfil,1,nil,tp) then
        Duel.SetChainLimit(s.chainlim)
    end
end
function s.atkncon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return a:IsControler(1-tp) and d and d:IsSetCard(0x28a) and d:IsType(TYPE_LINK)
end
function s.atknfil(c)
    return c:IsSetCard(0x28c) and c:IsAbleToGrave()
end
function s.atknt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanSendtoGrave(tp)
    and Duel.IsExistingMatchingCard(s.atknfil,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOGRAVE,nil,1,0,0)
end
function s.atknop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.atknfil,tp,LOCATION_DECK,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local sc=g:Select(tp,1,1,nil)
        Duel.SendtoGrave(sc,REASON_EFFECT)
        Duel.BreakEffect()
        Duel.NegateAttack()
    end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp)
end
function s.tgt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,0,3)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.DiscardDeck(tp,3,REASON_EFFECT)
end