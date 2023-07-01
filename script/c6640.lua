--Tea Party Gathering
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Take 1 "Tea Party" monster from deck
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.montarget)
    c:RegisterEffect(e1)
    --When placed faceup
    local e2=e1:Clone()
    e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_MOVE)
    e2:SetCondition(s.cond)
    c:RegisterEffect(e2)
    --Return 1 "Tea Party" to the hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.ctarget)
    e3:SetOperation(s.coperate)
    c:RegisterEffect(e3)
    --Return to deck during End Phase
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTarget(s.tgtg)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)
end
s.listed_series={0x294}
function s.mdeck(c)
    return c:IsSetCard(0x294) and c:IsMonster()
end
function s.montarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    if Duel.IsPlayerCanSendtoHand(tp)
    and Duel.IsExistingMatchingCard(s.mdeck,tp,LOCATION_DECK,0,1,nil)
    and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
        e:SetOperation(s.monoperate)
        Duel.SetOperationInfo(0,CATEGORY_SEARCH,nil,1,tp,LOCATION_DECK)
        Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    else
        e:SetCategory(0)
        e:SetOperation(nil)
    end
end
function s.monoperate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.SelectMatchingCard(tp,s.mdeck,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
    if c and tc then
        aux.ToHandOrElse(tc,tp,function(c) 
            return Duel.CheckPendulumZones(tp) end,
            function(c) Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end,
            aux.Stringid(id,3))
    end
end
function s.cfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x294) and c:IsOriginalType(TYPE_MONSTER)
end
function s.ctarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.cfilter(chkc) and chkc:IsCanBeEffectTarget(e)
        and chkc:IsControler(tp) end
    if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsPlayerCanSendtoHand(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local tc=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,tc,1,0,0)
end
function s.cfilter2(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER) and c:IsLevel(7)
end
function s.tograve(c)
    return c:IsSetCard(0x294)
end
function s.coperate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c and tc and Duel.IsPlayerCanSendtoHand(tp) and Duel.SendtoHand(tc,tp,REASON_EFFECT)>0
        and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,4))then
            Duel.BreakEffect()
            local tograve=Duel.SelectMatchingCard(tp,s.tograve,tp,LOCATION_DECK,0,1,1,nil)
            Duel.SendtoGrave(tograve,REASON_EFFECT)
        end
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
function s.cond(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_SZONE) and c:IsFaceup()
end