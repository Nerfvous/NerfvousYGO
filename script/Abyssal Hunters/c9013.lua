--Laurentina, the Saw of Madness
--Scripted by Nerfvous, NyaBox
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon.
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
    --Battle indestructible
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --Attach as material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.attc)
    e2:SetOperation(s.attop)
    e2:SetCountLimit(1,{id,0})
    c:RegisterEffect(e2)
    --Detach and apply multiple effects (refer to Redoer)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(TIMING_BATTLE_PHASE,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_PHASE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function () return Duel.IsBattlePhase() end)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
s.listed_series={0x384}

function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0
end
function s.attc(e,tp,eg,ep,ev,re,r,rp,chk,chkc) --Legality activation
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsForbidden() end
    if chk==0 then return
    Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsFaceup),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
    local tc=Duel.SelectTarget(tp,aux.NecroValleyFilter(Card.IsFaceup),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil):GetFirst()
    Duel.SetOperationInfo(0,0,tc,1,tp,LOCATION_GRAVE)
end
function s.attop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not c or not tc or not tc:IsRelateToEffect(e) then return end
    Duel.Overlay(c,tc)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 end
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetDecktopGroup(1-tp,1)
	if c:IsRelateToEffect(e) and #g==1 then
		Duel.DisableShuffleCheck()
		Duel.Overlay(c,g)
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsMonster,nil)<=1
		and sg:FilterCount(Card.IsSpell,nil)<=1
		and sg:FilterCount(Card.IsTrap,nil)<=1
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local ty=0
	--Change this
	if Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_MZONE,0,1,c) then ty=ty | TYPE_MONSTER | TYPE_SPELL end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCanChangePosition),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then ty=ty | TYPE_TRAP end
	if chk==0 then return ty>0 and g:IsExists(Card.IsType,1,nil,ty) end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=c:GetOverlayGroup()
	local ty=0
	if c:IsAbleToRemove() then ty=ty | TYPE_MONSTER end
	--if Duel.IsPlayerCanDraw(tp,1) then ty=ty | TYPE_SPELL end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_MZONE,0,1,c) then ty=ty | TYPE_SPELL end
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) then ty=ty | TYPE_TRAP end
	if Duel.IsExistingTarget(Card.IsCanTurnSet,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) then ty=ty | TYPE_TRAP end
	if ty==0 then return end
	local sg=aux.SelectUnselectGroup(g:Filter(Card.IsType,nil,ty),e,tp,1,3,s.rescon,1,tp,HINTMSG_REMOVEXYZ)
	local lb=0
	for tc in aux.Next(sg) do
		lb=lb | tc:GetType()
	end
	lb=lb & 0x7
	Duel.SendtoGrave(sg,REASON_EFFECT)
	Duel.RaiseSingleEvent(c,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	Duel.BreakEffect()
	if lb & TYPE_MONSTER ~=0 then
		--Other cards cannot be targeted for battle
		local atlim=Effect.CreateEffect(c)
		atlim:SetType(EFFECT_TYPE_FIELD)
		atlim:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		atlim:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		atlim:SetReset(RESET_PHASE+PHASE_END)
		atlim:SetRange(LOCATION_MZONE)
		atlim:SetTargetRange(0,LOCATION_MZONE)
		atlim:SetValue(s.filtg)
		c:RegisterEffect(atlim)
		--No battle damage involving this card
		local abd=Effect.CreateEffect(c)
		abd:SetType(EFFECT_TYPE_SINGLE)
		abd:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		abd:SetReset(RESET_PHASE+RESETS_STANDARD+PHASE_END)
		abd:SetValue(1)
		c:RegisterEffect(abd)
	end
	if lb & TYPE_SPELL ~=0 then
		--cannot be destroyed by card effects except for this card
        local indes=Effect.CreateEffect(c)
        indes:SetType(EFFECT_TYPE_FIELD)
        indes:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        indes:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		indes:SetReset(RESET_PHASE+PHASE_END)
        indes:SetRange(LOCATION_MZONE)
        indes:SetTargetRange(LOCATION_MZONE,0)
        indes:SetTarget(s.filtg)
		indes:SetValue(1)
		Duel.RegisterEffect(indes,tp)
	end
	if lb & TYPE_TRAP ~=0 then
        local sg=Duel.SelectTarget(tp,Card.IsCanTurnSet,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		Duel.ChangePosition(sg,POS_FACEDOWN)
	end
end
--Can only target Abyssal Hunters except itself
function s.filtg(e,c)
	return c~=e:GetHandler()
end