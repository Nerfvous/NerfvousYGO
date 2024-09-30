--C&C, Engaging Target!
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Cannot be used as materials
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,{id,0})
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e1:SetTarget(s.mattg)
    e1:SetOperation(s.matop)
    c:RegisterEffect(e1)
    --Add to Extra Deck
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.txdtg)
    e2:SetOperation(s.txdop)
    c:RegisterEffect(e2)
end
s.listed_series={0x258}
function s.matfil(c,e)
    return c:IsCanBeEffectTarget(e) and c:IsMonster() and c:IsFaceup()
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.matfil(chkc,e) end
    if chk==0 then return Duel.IsExistingTarget(s.matfil,tp,0,LOCATION_MZONE,1,nil,e)
        and Duel.IsExistingMatchingCard(Card.IsLink,tp,LOCATION_MZONE,0,1,nil,1)
     end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,s.matfil,tp,0,LOCATION_MZONE,1,1,nil,e):GetFirst()
    Duel.SetOperationInfo(0,0,tc,1,0,0)
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
    e1:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
    if tc:RegisterEffect(e1)~=0 then
        Duel.BreakEffect()
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET)
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
        e2:SetReset(RESET_PHASE+PHASE_END)
        e2:SetCondition(s.dmgcon)
        e2:SetTarget(s.dmgtg)
        e2:SetOperation(s.dmgop)
        Duel.RegisterEffect(e2,tp)
    end
end
function s.dmgfil(c,tp)
    return c:IsControler(tp) and c:IsSummonType(TYPE_LINK) and c:IsLink(1)
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.dmgfil,1,nil,tp)
end
function s.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(500)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end
function s.txdfil(c)
    return c:IsLink(1) and c:IsAbleToExtra() and c:IsFaceup()
end
function s.txdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.txdfil(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.txdfil,tp,LOCATION_GRAVE,0,1,nil)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,s.txdfil,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
    Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,tc,1,tp,LOCATION_EXTRA)
end
function s.txdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
    and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    and Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEDOWN,false,zone) then
        local e1=Effect.CreateEffect(c)
        e1:SetDescription(3300)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
        e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
        e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
        e1:SetValue(LOCATION_REMOVED)
        c:RegisterEffect(e1,true)
    end
end