function plan_serii = proverit_plan_serii_opytov(plan_serii)
if nargin < 1 || ~isstruct(plan_serii)
    error('%s', 'Для проверки плана серии требуется структура.');
end

obyazatelnye_polya = {
    'id_serii'
    'nazvanie'
    'spisok_scenariev'
    'chislo_povtorov'
    'varianty_parametrov_svyazi'
    'varianty_parametrov_zvenev'
    'varianty_parametrov_peredachi'
    'sohranyat_grafiki'
    'sohranyat_otchet'
    'ogranichenie_malogo_rezhima_proverki'
    };

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(plan_serii, imya_polya)
        error('%s', sprintf( ...
            'В плане серии отсутствует обязательное поле %s.', ...
            imya_polya));
    end
end

plan_serii.id_serii = proverit_nepustuyu_stroku( ...
    plan_serii.id_serii, ...
    'id_serii');
plan_serii.nazvanie = proverit_nepustuyu_stroku( ...
    plan_serii.nazvanie, ...
    'nazvanie');
plan_serii.spisok_scenariev = normalizovat_spisok_scenariev( ...
    plan_serii.spisok_scenariev);
plan_serii.chislo_povtorov = proverit_polozhitelnoe_celoe( ...
    plan_serii.chislo_povtorov, ...
    'chislo_povtorov');
plan_serii.sohranyat_grafiki = proverit_logicheskoe_znachenie( ...
    plan_serii.sohranyat_grafiki, ...
    'sohranyat_grafiki');
plan_serii.sohranyat_otchet = proverit_logicheskoe_znachenie( ...
    plan_serii.sohranyat_otchet, ...
    'sohranyat_otchet');
plan_serii.ogranichenie_malogo_rezhima_proverki = ...
    proverit_polozhitelnoe_celoe( ...
    plan_serii.ogranichenie_malogo_rezhima_proverki, ...
    'ogranichenie_malogo_rezhima_proverki');

plan_serii.varianty_parametrov_svyazi = normalizovat_varianty_parametrov( ...
    plan_serii.varianty_parametrov_svyazi, ...
    parametry_svyazi_po_umolchaniyu(), ...
    @proverit_parametry_svyazi, ...
    'varianty_parametrov_svyazi');
plan_serii.varianty_parametrov_zvenev = normalizovat_varianty_parametrov( ...
    plan_serii.varianty_parametrov_zvenev, ...
    parametry_zvenev_po_umolchaniyu(), ...
    @proverit_parametry_zvenev, ...
    'varianty_parametrov_zvenev');
plan_serii.varianty_parametrov_peredachi = normalizovat_varianty_parametrov( ...
    plan_serii.varianty_parametrov_peredachi, ...
    parametry_peredachi_po_umolchaniyu(), ...
    @proverit_parametry_peredachi, ...
    'varianty_parametrov_peredachi');

if isfield(plan_serii, 'primechanie')
    plan_serii.primechanie = char(string(plan_serii.primechanie));
else
    plan_serii.primechanie = '';
end

proverit_bezopasnost_plana(plan_serii);
end

function znachenie = proverit_nepustuyu_stroku(znachenie, imya_polya)
if strlength(string(znachenie)) == 0
    error('%s', sprintf( ...
        'Поле %s должно быть непустой строкой.', ...
        imya_polya));
end

znachenie = char(string(znachenie));
end

function spisok_scenariev = normalizovat_spisok_scenariev(spisok_scenariev)
if isstring(spisok_scenariev) || ischar(spisok_scenariev)
    spisok_scenariev = cellstr(string(spisok_scenariev));
elseif iscell(spisok_scenariev)
    spisok_scenariev = cellfun(@(znachenie) char(string(znachenie)), ...
        spisok_scenariev, 'UniformOutput', false);
else
    error('%s', 'Список сценариев серии должен быть строкой или списком строк.');
end

spisok_scenariev = spisok_scenariev(:).';
if isempty(spisok_scenariev) || any(cellfun(@isempty, spisok_scenariev))
    error('%s', 'План серии должен содержать непустой список сценариев.');
end
end

function varianty = normalizovat_varianty_parametrov(varianty, parametry_bazy, proverka, imya_polya)
if ~isstruct(varianty)
    error('%s', sprintf( ...
        'Поле %s должно содержать список структур параметров.', ...
        imya_polya));
end

if isempty(varianty)
    error('%s', sprintf( ...
        'Поле %s не должно быть пустым.', ...
        imya_polya));
end

varianty = varianty(:).';
spisok_poley_bazy = fieldnames(parametry_bazy);
parametry_po_umolchaniyu = proverka(parametry_bazy);
varianty_norm = repmat(parametry_po_umolchaniyu, 1, numel(varianty));

for nomer_varianta = 1:numel(varianty)
    variant = varianty(nomer_varianta);
    tekushchie_parametry = parametry_po_umolchaniyu;
    spisok_poley_varianta = fieldnames(variant);
    for nomer_polya = 1:numel(spisok_poley_varianta)
        imya_variantnogo_polya = spisok_poley_varianta{nomer_polya};
        if ~ismember(imya_variantnogo_polya, spisok_poley_bazy)
            error('%s', sprintf( ...
                'В поле %s обнаружен недопустимый параметр %s.', ...
                imya_polya, ...
                imya_variantnogo_polya));
        end
        tekushchie_parametry.(imya_variantnogo_polya) = ...
            variant.(imya_variantnogo_polya);
    end

    varianty_norm(nomer_varianta) = proverka(tekushchie_parametry);
end

varianty = varianty_norm;
end

function znachenie = proverit_polozhitelnoe_celoe(znachenie, imya_polya)
if ~isnumeric(znachenie) || ~isscalar(znachenie) || ~isfinite(znachenie)
    error('%s', sprintf( ...
        'Поле %s должно быть конечным числом.', ...
        imya_polya));
end

znachenie = double(znachenie);
if znachenie < 1 || abs(znachenie - round(znachenie)) > eps(max(1, abs(znachenie)))
    error('%s', sprintf( ...
        'Поле %s должно быть целым числом не меньше 1.', ...
        imya_polya));
end

znachenie = round(znachenie);
end

function znachenie = proverit_logicheskoe_znachenie(znachenie, imya_polya)
if ~(islogical(znachenie) && isscalar(znachenie)) ...
        && ~(isnumeric(znachenie) && isscalar(znachenie))
    error('%s', sprintf( ...
        'Поле %s должно быть логическим признаком.', ...
        imya_polya));
end

znachenie = logical(znachenie);
end

function proverit_bezopasnost_plana(plan_serii)
zapreshennye_fragmenty = {
    'боев'
    'поражен'
    'наведен'
    'людей'
    'вред'
    'обход защит'
    'подавлен'
    'скрытого управления'
    };

proveryaemye_znacheniya = [{plan_serii.id_serii}, {plan_serii.nazvanie}, plan_serii.spisok_scenariev];
for nomer_znacheniya = 1:numel(proveryaemye_znacheniya)
    tekst = lower(char(string(proveryaemye_znacheniya{nomer_znacheniya})));
    for nomer_fragmenta = 1:numel(zapreshennye_fragmenty)
        fragment = zapreshennye_fragmenty{nomer_fragmenta};
        if contains(tekst, fragment)
            error('%s', sprintf( ...
                'В плане серии обнаружен недопустимый фрагмент "%s".', ...
                fragment));
        end
    end
end
end
