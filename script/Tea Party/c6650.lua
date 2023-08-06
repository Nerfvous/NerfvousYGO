--Tea Party Supporter - Sisterhood
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --xyz summon
	Xyz.AddProcedure(c,nil,4,2)
	c:EnableReviveLimit()
    --Add pendulum procedure
    Pendulum.AddProcedure(c,false)
    --Special Summon this card and place a targeted Light Pendulum face-up monster you control in your Pendulum Zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN) 
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetCondition(s.pencon)
	e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    --Place a monster to the top of the deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptc)
    e2:SetOperation(s.activate)
    c:RegisterEffect(e2)
    --Attach 1 Light monster
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.atmatc)
    e3:SetOperation(s.atmatop)
    c:RegisterEffect(e3)
    --Reverse special summon
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1,{id,3})
    e4:SetCost(s.rspcost)
    e4:SetCondition(s.rspcon)
    e4:SetTarget(s.rspc)
    e4:SetOperation(s.rspop)
    c:RegisterEffect(e4)
    --Light Pendulum monsters to be detached as mats will instead be sent to the ED
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,4))
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    --e5:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,{id,4})
    e5:SetCondition(s.dedcon)
    e5:SetTarget(s.dedt)
    e5:SetOperation(s.dedop)
    c:RegisterEffect(e5)
end
s.listed_series={0x294}
--Checks if a Light Pendulum faceup card is up (checking if it is a monster is kinda redundant)
function s.cfilter(c)
    return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
end
function s.pencon(e,tp)
    return Duel.IsTurnPlayer(tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
        and s.cfilter(chkc) end
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) and not Duel.CheckPendulumZones(tp) then return end
    Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.confil(c,e)
    local tp=e:GetHandlerPlayer()
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
    and c:IsLevel(7) and c:IsControler(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.confil,1,nil,e)
end
function s.sptc(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_MZONE)
end
function s.actfil(c)
    return c:IsMonster() and c:IsAbleToDeck()
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(s.actfil,tp,0,LOCATION_MZONE,nil)>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --Registers the effect to the player as a lingering effect
    if c:IsRelateToEffect(e)
        and Duel.GetMatchingGroupCount(s.actfil,tp,0,LOCATION_MZONE,nil)>0 then
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(aux.Stringid(id,1))
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetReset(RESET_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        --Condition is important so it knows if it can procede
        e1:SetCondition(s.spcon2)
        e1:SetOperation(s.spop)
        Duel.RegisterEffect(e1,tp)
    end
end
--The actual function that sends the card to deck
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
    local sc=g:Select(1-tp,1,1,nil)
    --Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
    Duel.HintSelection(sc)
    Duel.SendtoDeck(sc,PLAYER_NONE,SEQ_DECKTOP,1-tp)
end
function s.atmat(c,e)
    local tp=c:GetControler()
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsMonster()
    and c:IsLocation(LOCATION_MZONE|LOCATION_HAND) or (c:IsFaceup() and c:IsLocation(LOCATION_EXTRA))
    and not c:IsImmuneToEffect(e)
end
function s.atmatc(e,tp,eg,ep,ev,re,r,rp,chk)
    local hfed=LOCATION_HAND|LOCATION_MZONE|LOCATION_EXTRA
    if chk==0 then return Duel.IsExistingMatchingCard(s.atmat,tp,hfed,0,1,e:GetHandler(),e)
    and e:GetHandler():IsType(TYPE_XYZ) end
end
function s.atmatop(e,tp,eg,ep,ev,re,r,rp)
    local hfed=LOCATION_HAND|LOCATION_MZONE|LOCATION_EXTRA
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.atmat,tp,hfed,0,c,e)
    if #g<1 or not c:IsRelateToEffect(e) or c:IsFacedown() then
        return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local sc=g:Select(tp,1,1,nil)
    Duel.Overlay(c,sc,true)
end
function s.rspcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.rspcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsTurnPlayer(1-tp)
end
function s.rspfil(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_PENDULUM)
end
function s.rspc(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsCanBeEffectTarget(e) and chkc:IsSpecialSummonable()
    and chkc:IsLocation(LOCATION_PZONE) and s.rspfil(chkc) end
    if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
    and Duel.IsExistingTarget(aux.FaceupFilter(s.rspfil),tp,LOCATION_PZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local tc=Duel.SelectTarget(tp,aux.FaceupFilter(s.rspfil),tp,LOCATION_PZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,LOCATION_PZONE)
end
function s.rspop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not tc or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
    if Duel.SpecialSummon(tc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
    and c:IsRelateToEffect(e)
    and Duel.CheckPendulumZones(tp)
    and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
function s.dedcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return (r&REASON_COST)~=0 and re:IsActiveType(TYPE_XYZ)
        and ev==1 and rc:GetOverlayGroup():IsExists(s.rspfil,1,nil)
end
function s.dedt(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_XYZ)
    and chkc:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_EXTRA)
    Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_GRAVE)
end
function s.dedop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    --Only Light Pendulum monsters can be selected for detachment
    local g=rc:GetOverlayGroup():Filter(s.rspfil,nil)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)
    return Duel.SendtoExtraP(sc,tp,REASON_COST)
end
