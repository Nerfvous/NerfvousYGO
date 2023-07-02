--Tea Party - Make-Up Work Club
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    -- Add 1 "Tea Party" monster from the Pendulum Zones to the ED faceup
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,{id,0})
    e1:SetTarget(s.ctarget)
    c:RegisterEffect(e1)
    --Activate
    local e2=e1:Clone()
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_MOVE)
    e2:SetCondition(s.ccond)
    c:RegisterEffect(e2)
    --Faceup spells and traps are indestructible
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.indtg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
    --Return during End Phase
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetTarget(s.tgtg)
    e4:SetOperation(s.tgop)
    c:RegisterEffect(e4)
end
s.listed_series={0x294}
function s.cpenfil(c)
    return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0x294)
end
function s.cdeckfil(c)
    return c:GetLevel()<=4 and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
end
function s.ctarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsCanBeEffectTarget(e) and chkc:IsLocation(LOCATION_PZONE)
        and chkc:IsControler(tp) and s.cpenfil(chkc) end
    if chk==0 then return true end
    if Duel.IsExistingTarget(s.cpenfil,tp,LOCATION_PZONE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        e:SetCategory(CATEGORY_TOEXTRA)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        e:SetOperation(s.cop)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
        local g=Duel.SelectTarget(tp,s.cpenfil,tp,LOCATION_PZONE,0,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
    else
        e:SetCategory(0)
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.cop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if Duel.SendtoExtraP(tc,tp,REASON_EFFECT)
        and Duel.IsExistingMatchingCard(s.cdeckfil,tp,LOCATION_DECK,0,1,nil)
        and Duel.CheckPendulumZones(tp) then
        Duel.BreakEffect()
        local notc=Duel.GetMatchingGroup(s.cdeckfil,tp,LOCATION_DECK,0,tc:GetCode(),tp)
        local ct=notc:Select(tp,1,1,tc:GetCode(),tp):GetFirst()
        Duel.MoveToField(ct,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
end
function s.ccond(e)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_SZONE) and c:IsFaceup()
end
--Only affect faceup spells/traps
function s.indtg(e,c)
    return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsFaceup()
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
