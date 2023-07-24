--Ascended Mystique Tsumi
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Link summon with at least 1 "Mystique" monster
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2,3,s.lnmats)
    --Special summon by banishing
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
    e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spbcon)
	e1:SetTarget(s.spbt)
	e1:SetOperation(s.spbop)
	c:RegisterEffect(e1)
    --Banish cards
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCondition(s.bnshcon)
    e2:SetTarget(s.bnsht)
    e2:SetOperation(s.bnshop)
    c:RegisterEffect(e2,false,REGISTER_FLAG_TELLAR)
    --Negate
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetCost(s.ngtcost)
    e3:SetCondition(s.ngtcon)
    e3:SetTarget(s.ngtt)
    e3:SetOperation(s.ngtop)
    c:RegisterEffect(e3)
end
s.listed_series={0x28a}
function s.lnmats(g,lc,sumtype,tp)
    return g:IsExists(Card.IsSetCard,1,nil,0x28a,lc,sumtype,tp)
end
function s.spbfil(c)
    return c:IsAbleToRemoveAsCost() and ((c:IsSetCard(0x28c)
     and c:IsLocation(LOCATION_SZONE+LOCATION_GRAVE)) or c:IsCode(6504) and c:IsLocation(LOCATION_MZONE))
     and c:IsFaceup()
end
function s.rescon(sg,e,tp,mg)
    local lc=Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())
    local c1=sg:GetClassCount(Card.GetLocation)
    local c2=#sg
    if lc>0 then
        return c1==c2,c1~=c2 end
    return false
end
function s.spbcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spbfil),tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
    if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)==#g
    or g:FilterCount(Card.IsLocation,nil,LOCATION_SZONE)==#g
    or g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==#g then return false end
    return aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
end
function s.spbt(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spbfil),tp,LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,nil)
    local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
    if #sg>0 then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    end
    return false
end
function s.spbop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    Duel.Remove(sg,POS_FACEUP,REASON_COST)
    c:SetMaterial(sg)
    sg:DeleteGroup()
end
function s.bnshcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.bnsht(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local g=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,0x28c),tp,LOCATION_SZONE,0,1,nil)
    if chkc then return chkc:IsCanBeEffectTarget(e) and chkc:IsFaceup()
    and chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE)
    and chkc:IsAbleToRemove() end
    if chk==0 then return g>0
    and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,1,nil)
    and Duel.IsPlayerCanRemove(tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsCanBeEffectTarget,e),tp,0,LOCATION_GRAVE,1,g,nil)
    Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.bnshop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetTargetCards(e)
    if #sg>0 then
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end
function s.costfil(c)
    return c:IsAbleToDeckAsCost() and c:IsSetCard(0x28c) and not c:IsMonster()
end
function s.ngtcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return
    Duel.IsExistingMatchingCard(aux.FaceupFilter(s.costfil),tp,LOCATION_REMOVED,0,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(s.costfil),tp,LOCATION_REMOVED,0,2,2,nil)
    Duel.SendtoDeck(sg,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.ngtcon(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return re:IsActiveType(TYPE_MONSTER) and ep~=tp and Duel.IsChainDisablable(ev)
end
function s.ngtt(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if Duel.IsExistingMatchingCard(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
    end
end
function s.ngtop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
    if Duel.NegateEffect(ev) and #g>0
    and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sc=g:Select(tp,1,1,nil)
        Duel.Destroy(sc,REASON_EFFECT)
    end
end
