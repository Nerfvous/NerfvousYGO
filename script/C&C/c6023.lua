--C&C, Mission Accomplished
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x1600)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    c:RegisterEffect(e1)
    --Place counter
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.pcop)
    c:RegisterEffect(e2)
    --Double ATK
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id)
    e4:SetCost(s.optcost)
    e4:SetTarget(s.opttg)
    e4:SetOperation(s.optop)
    c:RegisterEffect(e4)
    --Add 1 C&C from deck or gy to hand
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCategory(CATEGORY_TOHAND)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1,id)
    e5:SetCost(s.thcost)
    e5:SetTarget(s.thtg)
    e5:SetOperation(s.thop)
    c:RegisterEffect(e5)
    --Unaffected
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,2))
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_CHAINING)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCountLimit(1,id)
    e6:SetCost(s.immcost)
    e6:SetCondition(s.immcon)
    e6:SetTarget(s.immtg)
    e6:SetOperation(s.immop)
    c:RegisterEffect(e6)
end
s.listed_series={0x258}
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if ep~=tp and tp==rp and ev>=500 and r==REASON_EFFECT then
        local ct=math.floor(ev/500)
        c:AddCounter(0x1600,ct)
    end
end
function s.optfil1(c)
    return c:IsLink(1)
end
function s.optcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1600,2,REASON_COST) end
    Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp,0x1600,2,REASON_COST)
end
function s.opttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return s.optfil1(chkc,e) and chkc:IsLocation(LOCATION_MZONE) end
    if chk==0 then return Duel.IsExistingMatchingCard(s.optfil1,tp,LOCATION_MZONE,0,1,nil,e) end
    Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,0,0)
end
function s.optop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,s.optfil1,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
    if c:IsRelateToEffect(e) and tc then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
        e1:SetValue((tc:GetAttack())*2)
        tc:RegisterEffect(e1)
    end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1600,4,REASON_COST) end
    Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp,0x1600,2,REASON_COST)
end
function s.optfil2(c)
    return c:IsAbleToHand() and c:IsSetCard(0x258)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.optfil2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local tc=Duel.SelectMatchingCard(tp,s.optfil2,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
    if c:IsRelateToEffect(e) and tc then
        Duel.SendtoHand(tc,tp,REASON_EFFECT)
    end
end
function s.immcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1600,6,REASON_COST) end
    Duel.Hint(HINT_OPSELECTED,tp,e:GetDescription())
    e:GetHandler():RemoveCounter(tp,0x1600,0,REASON_COST)
end
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
   return ep~=tp
end
function s.immfil(c)
    return c:IsSetCard(0x258) and c:IsFaceup() and c:IsMonster()
end
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.immfil,tp,LOCATION_MZONE,0,1,nil) end
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(s.immfil))
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    if re:GetActiveType()==TYPE_MONSTER then
        e1:SetDescription(aux.Stringid(id,3))
        e1:SetValue(s.atlim1)
    end
    if re:GetActiveType()==TYPE_SPELL then
        e1:SetDescription(aux.Stringid(id,4))
        e1:SetValue(s.atlim2)
    end
    if re:GetActiveType()==TYPE_TRAP then
        e1:SetDescription(aux.Stringid(id,5))
        e1:SetValue(s.atlim3)
    end
    Duel.RegisterEffect(e1,tp)
end
function s.atlim1(e,re,tp)
    return re:IsActiveType(TYPE_MONSTER)
end
function s.atlim2(e,re,tp)
    return re:IsActiveType(TYPE_SPELL)
end
function s.atlim3(e,re,tp)
    return re:IsActiveType(TYPE_TRAP)
end