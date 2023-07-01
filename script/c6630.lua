--Tea Party - Eat Your Treats
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Change face-up monsters to face-down defense
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.gtarget)
    c:RegisterEffect(e1)
    --Activate
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_MOVE)
    e1:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.cond)
    c:RegisterEffect(e2)
    --Activation limit during battle
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.atkcon)
    c:RegisterEffect(e3)
    --Return during End Phase
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.tgtg)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)
end
s.listed_series={0x294}
function s.gfilter(c)
    return c:IsMonster() and c:IsCanTurnSet()
end
function s.gtpfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7)
end
--[[ function s.gtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsCanBeEffectTarget(e) and chkc:IsCanTurnSet()
        and chkc:IsControler(1-tp) and s.gfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.gfilter,tp,0,LOCATION_MZONE,1,nil) end
    local ct=1
    if Duel.GetMatchingGroupCount(s.gtpfilter,tp,LOCATION_MZONE,0,nil)>=1 then ct=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.gfilter,tp,0,LOCATION_MZONE,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetTargetCards(e)
    Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end ]]
function s.gtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsCanBeEffectTarget(e)
    and s.gfilter(chkc) end
    if chk==0 then return true end
    if Duel.IsExistingTarget(s.gfilter,tp,0,LOCATION_MZONE,1,nil)
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        e:SetCategory(CATEGORY_POSITION)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e:SetOperation(s.gop)
        local ct=1
        if Duel.GetMatchingGroupCount(s.gtpfilter,tp,LOCATION_MZONE,0,nil) then ct=2 end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectTarget(tp,s.gfilter,tp,0,LOCATION_MZONE,1,ct,nil)
        Duel.SetOperationInfo(0,CATEGORY_POSITION,g,ct,0,0)
    else
        e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
    end
end
function s.cond(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_SZONE) and c:IsFaceup()
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetTargetCards(e)
    Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
function s.atkcon(e,c)
    return Duel.GetAttacker()==e:GetHandler()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
    end
end
