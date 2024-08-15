--Avalon La Fae
--Scripted by Nerfvous
local s,id = GetID()
function s.initial_effect(c)
    --Add 1 Fae card
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --Untargetable by effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetValue(s.tlimit)
    c:RegisterEffect(e2)
    -- and battle
    local e3=e2:Clone()
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.tlimit)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    --Draw
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.drtg)
    e4:SetOperation(s.drop)
    c:RegisterEffect(e4)
end
s.listed_series={0x29e}
--Filter for Fae card
function s.thfilter(c)
    return c:IsAbleToHand() and c:IsSetCard(0x29e)
end
--Add 1 Fae card to hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end
--Untargetable by effects
function s.tlimit(e,c)
    return c:IsCode(6704)
end
--Target filter
function s.tdfilter(c)
	return c:IsSetCard(0x29e) and c:IsQuickPlaySpell() and c:IsAbleToDeck()
end
--Target cards
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#g)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		if ct==0 then return end
		if ct>1 then Duel.SortDeckbottom(tp,tp,ct) end
		Duel.BreakEffect()
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end