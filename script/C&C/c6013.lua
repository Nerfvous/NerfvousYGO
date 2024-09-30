--C&C Callsign 02, Airborne, Beginning Support
--Scripted by Nerfvous
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned properly
    c:EnableReviveLimit()
    --Special Summon Karin once per turn
    c:SetSPSummonOnce(id)
    --Link summon
    Link.AddProcedure(c,s.lsmats,1,1)
    --Equip
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,{id,0})
    e1:SetRange(LOCATION_MZONE)
    e1:SetTarget(s.equiptg)
    e1:SetOperation(s.equipop)
    c:RegisterEffect(e1)
    --Destroy attacking/attacked opp's monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BATTLE_START)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    --Special summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_series={0x258}
--Non-link C&C monsters
function s.lsmats(c,scard,sumtype,tp)
    return c:IsSetCard(0x258,scard,sumtype,tp) and not c:IsType(TYPE_LINK,scard,sumtype,tp)
end
function s.etgfil(c,e,tp)
    return c:IsCanBeEffectTarget(e) and c:IsMonster() and c:IsControler(tp) and c:IsLinkMonster()
end
function s.equiptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.etgfil(chkc,e,tp) and not chkc==c end
    if chk==0 then return Duel.IsExistingTarget(s.etgfil,tp,LOCATION_MZONE,0,1,c,e,tp)
        and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.etgfil,tp,LOCATION_MZONE,0,1,1,c,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function s.equipop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc=Duel.GetFirstTarget()
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc and tc:IsRelateToEffect(e) then
        Duel.Equip(tp,c,tc,true)
        --Equip limit
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
        e1:SetLabelObject(tc)
        c:RegisterEffect(e1)
    else
        Duel.SendtoGrave(c,REASON_RULE)
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local atka,atkt=Duel.GetBattleMonster(tp)
    local c=e:GetHandler()
    local eqg=atka:GetEquipGroup()
    return atka and atkt and eqg and eqg:IsContains(c)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    local _,atkt=Duel.GetBattleMonster(tp)
    if chk==0 then return atkt end
    e:SetLabelObject(atkt)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,atkt,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local atkt=e:GetLabelObject()
    local atk=math.floor(atkt:GetAttack()/2)
    if atk<=0 then atk=0 end
    if atkt and atkt:IsRelateToBattle() and atkt:IsControler(1-tp)
    and Duel.Destroy(atkt,REASON_EFFECT)~=0 then
        Duel.Damage(1-tp,atk,REASON_EFFECT)
    end
end
function s.spfil(c,e)
    local tp=e:GetHandlerPlayer()
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.spfil(chkc,e) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.GetMatchingGroupCount(s.spfil,tp,LOCATION_GRAVE,0,nil,e)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,s.spfil,tp,LOCATION_GRAVE,0,1,1,nil,e)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
function s.tgfil(c,e)
    return c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local c=e:GetHandler()
    local tctype=tc:IsCode(6002)
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
        and Duel.GetMatchingGroupCount(s.tgfil,tp,0,LOCATION_MZONE,nil,e)>0
        and tctype and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
            local tg=Duel.SelectMatchingCard(tp,s.tgfil,tp,0,LOCATION_MZONE,1,1,nil,e):GetFirst()
            local e1=Effect.CreateEffect(c)
            e1:SetDescription(3206)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CANNOT_ATTACK)
            e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
            tg:RegisterEffect(e1)
    end
end