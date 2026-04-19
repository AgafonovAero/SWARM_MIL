function [id_sleduyushchego_bvs, prichina] = vybrat_sleduyushchii_bvs(soobshchenie, graf_svyaznosti, sostoyaniya_bvs, dannye_zvenev, parametry_peredachi)
if nargin < 5
    error('%s', [ ...
        'Для выбора следующего БВС требуются сообщение, граф связности, состояния БВС, ' ...
        'данные звеньев и параметры передачи.' ...
        ]);
end

parametry_peredachi = proverit_parametry_peredachi(parametry_peredachi);
soobshchenie = proverit_soobshchenie(soobshchenie);
[id_bvs, matrica_smeznosti, matrica_rasstoyanii_m] = proverit_graf(graf_svyaznosti);
sostoyaniya_bvs = proverit_sostoyaniya(sostoyaniya_bvs, id_bvs);
dannye_zvenev = proverit_dannye_zvenev(dannye_zvenev);

id_sleduyushchego_bvs = '';
prichina = 'Подходящий связный сосед для передачи не найден.';

indeks_tekushchego = nayti_indeks(id_bvs, soobshchenie.tekushchii_bvs, ...
    'текущего БВС сообщения');
indeks_poluchatelya = nayti_indeks(id_bvs, soobshchenie.id_poluchatelya, ...
    'получателя сообщения');

if ~sostoyaniya_bvs(indeks_tekushchego).rabotosposoben
    prichina = 'Текущий БВС сообщения неработоспособен.';
    return
end

if ~sostoyaniya_bvs(indeks_poluchatelya).rabotosposoben
    prichina = 'Получатель сообщения неработоспособен.';
    return
end

sosedi = find(matrica_smeznosti(indeks_tekushchego, :));
if isempty(sosedi)
    prichina = 'У текущего БВС нет доступных соседей по графу связности.';
    return
end

if parametry_peredachi.razreshit_pryamuyu_peredachu ...
        && matrica_smeznosti(indeks_tekushchego, indeks_poluchatelya)
    id_sleduyushchego_bvs = soobshchenie.id_poluchatelya;
    prichina = 'Получатель является непосредственным соседом.';
    return
end

if parametry_peredachi.propuskat_cherez_golovnye_bvs
    [id_tseli, prichina_marshruta] = opredelit_tsel_cherez_golovnye_bvs( ...
        soobshchenie, ...
        dannye_zvenev);

    if ~isempty(id_tseli)
        [id_sleduyushchego_bvs, naiden] = vybrat_soseda_k_tseli( ...
            id_tseli, ...
            indeks_tekushchego, ...
            sosedi, ...
            id_bvs, ...
            matrica_smeznosti, ...
            matrica_rasstoyanii_m);
        if naiden
            prichina = prichina_marshruta;
            return
        end
    end
end

[id_sleduyushchego_bvs, naiden] = vybrat_soseda_k_tseli( ...
    soobshchenie.id_poluchatelya, ...
    indeks_tekushchego, ...
    sosedi, ...
    id_bvs, ...
    matrica_smeznosti, ...
    matrica_rasstoyanii_m);

if naiden
    prichina = 'Выбран сосед с наибольшим продвижением к получателю.';
else
    id_sleduyushchego_bvs = '';
    prichina = 'Подходящий связный сосед для продвижения к получателю не найден.';
end
end

function [id_tseli, prichina] = opredelit_tsel_cherez_golovnye_bvs(soobshchenie, dannye_zvenev)
id_tseli = '';
prichina = '';

[tekushchee_zveno, nomer_tekushchego_zvena] = nayti_zveno_po_bvs( ...
    dannye_zvenev.zvenya, ...
    soobshchenie.tekushchii_bvs);
[zveno_poluchatelya, nomer_zvena_poluchatelya] = nayti_zveno_po_bvs( ...
    dannye_zvenev.zvenya, ...
    soobshchenie.id_poluchatelya);

if nomer_tekushchego_zvena == 0 || nomer_zvena_poluchatelya == 0
    return
end

golovnoi_tekushchego_zvena = poluchit_golovnoi_bvs_iz_zvena(tekushchee_zveno);
golovnoi_zvena_poluchatelya = poluchit_golovnoi_bvs_iz_zvena(zveno_poluchatelya);

if nomer_tekushchego_zvena == nomer_zvena_poluchatelya
    if ~isempty(golovnoi_tekushchego_zvena) ...
            && ~strcmp(soobshchenie.tekushchii_bvs, golovnoi_tekushchego_zvena) ...
            && ~strcmp(golovnoi_tekushchego_zvena, soobshchenie.id_poluchatelya)
        id_tseli = golovnoi_tekushchego_zvena;
        prichina = 'Выбран путь к головному БВС текущего звена.';
    else
        id_tseli = soobshchenie.id_poluchatelya;
        prichina = 'Выбран путь к получателю внутри текущего звена.';
    end
    return
end

if ~isempty(golovnoi_tekushchego_zvena) ...
        && ~strcmp(soobshchenie.tekushchii_bvs, golovnoi_tekushchego_zvena)
    id_tseli = golovnoi_tekushchego_zvena;
    prichina = 'Выбран путь к головному БВС текущего звена.';
    return
end

if ~isempty(golovnoi_zvena_poluchatelya) ...
        && ~strcmp(soobshchenie.tekushchii_bvs, golovnoi_zvena_poluchatelya)
    id_tseli = golovnoi_zvena_poluchatelya;
    prichina = 'Выбран путь к головному БВС звена получателя.';
    return
end

id_tseli = soobshchenie.id_poluchatelya;
prichina = 'Выбран путь от головного БВС звена к получателю.';
end

function [id_sleduyushchego_bvs, naiden] = vybrat_soseda_k_tseli(id_tseli, indeks_tekushchego, sosedi, id_bvs, matrica_smeznosti, matrica_rasstoyanii_m)
indeks_tseli = nayti_indeks(id_bvs, id_tseli, 'целевого БВС');

if matrica_smeznosti(indeks_tekushchego, indeks_tseli)
    id_sleduyushchego_bvs = id_tseli;
    naiden = true;
    return
end

tekushchee_rasstoyanie = matrica_rasstoyanii_m(indeks_tekushchego, indeks_tseli);
kandidaty = [];

for nomer_soseda = 1:numel(sosedi)
    indeks_soseda = sosedi(nomer_soseda);
    rasstoyanie_soseda = matrica_rasstoyanii_m(indeks_soseda, indeks_tseli);
    if rasstoyanie_soseda + 1e-9 < tekushchee_rasstoyanie
        kandidaty(end + 1, :) = [ ... %#ok<AGROW>
            indeks_soseda, ...
            rasstoyanie_soseda, ...
            -matrica_rasstoyanii_m(indeks_tekushchego, indeks_soseda)];
    end
end

if isempty(kandidaty)
    id_sleduyushchego_bvs = '';
    naiden = false;
    return
end

[~, poryadok] = sortrows(kandidaty, [2 3 1]);
id_sleduyushchego_bvs = id_bvs{kandidaty(poryadok(1), 1)};
naiden = true;
end

function [zveno, nomer_zvena] = nayti_zveno_po_bvs(zvenya, id_bvs)
zveno = struct();
nomer_zvena = 0;

for indeks_zvena = 1:numel(zvenya)
    if any(strcmp(zvenya(indeks_zvena).id_bvs, id_bvs))
        zveno = zvenya(indeks_zvena);
        nomer_zvena = indeks_zvena;
        return
    end
end
end

function golovnoi_bvs = poluchit_golovnoi_bvs_iz_zvena(zveno)
golovnoi_bvs = '';
if isstruct(zveno) && isfield(zveno, 'golovnoi_bvs') ...
        && strlength(string(zveno.golovnoi_bvs)) > 0
    golovnoi_bvs = char(string(zveno.golovnoi_bvs));
end
end

function dannye_zvenev = proverit_dannye_zvenev(dannye_zvenev)
if ~isstruct(dannye_zvenev) ...
        || ~isfield(dannye_zvenev, 'zvenya') ...
        || ~isfield(dannye_zvenev, 'golovnye_bvs')
    error('%s', [ ...
        'Данные звеньев должны содержать поля zvenya и golovnye_bvs.' ...
        ]);
end
end

function sostoyaniya_bvs = proverit_sostoyaniya(sostoyaniya_bvs, id_bvs)
if ~isstruct(sostoyaniya_bvs) || numel(sostoyaniya_bvs) ~= numel(id_bvs)
    error('%s', ...
        'Состояния БВС для передачи заданы некорректно.');
end

identifikatory = cell(1, numel(sostoyaniya_bvs));
for nomer_bvs = 1:numel(sostoyaniya_bvs)
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs( ...
        sostoyaniya_bvs(nomer_bvs));
    identifikatory{nomer_bvs} = sostoyaniya_bvs(nomer_bvs).id_bvs;
end

if ~isempty(setxor(identifikatory, id_bvs))
    error('%s', ...
        'Состав состояний БВС не совпадает с графом связности.');
end
end

function [id_bvs, matrica_smeznosti, matrica_rasstoyanii_m] = proverit_graf(graf_svyaznosti)
obyazatelnye_polya = {
    'id_bvs'
    'matrica_smeznosti'
    'matrica_rasstoyanii_m'
    };

if ~isstruct(graf_svyaznosti)
    error('%s', ...
        'Граф связности должен быть передан в виде структуры.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(graf_svyaznosti, imya_polya)
        error('%s', sprintf( ...
            'В графе связности отсутствует поле %s.', ...
            imya_polya));
    end
end

id_bvs = normalizovat_id_bvs(graf_svyaznosti.id_bvs);
matrica_smeznosti = logical(graf_svyaznosti.matrica_smeznosti);
matrica_rasstoyanii_m = double(graf_svyaznosti.matrica_rasstoyanii_m);
end

function soobshchenie = proverit_soobshchenie(soobshchenie)
obyazatelnye_polya = {
    'id_soobshcheniya'
    'id_otpravitelya'
    'id_poluchatelya'
    'tekushchii_bvs'
    'marshrut'
    'chislo_peresylok'
    };

if ~isstruct(soobshchenie)
    error('%s', ...
        'Сообщение для выбора следующего БВС должно быть структурой.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(soobshchenie, imya_polya)
        error('%s', sprintf( ...
            'В сообщении отсутствует поле %s.', ...
            imya_polya));
    end
end
end

function nomer_bvs = nayti_indeks(id_bvs, iskomyi_id_bvs, naznachenie)
nomer_bvs = find(strcmp(id_bvs, char(string(iskomyi_id_bvs))), 1);
if isempty(nomer_bvs)
    error('%s', sprintf( ...
        'Не найден идентификатор %s %s.', ...
        naznachenie, ...
        char(string(iskomyi_id_bvs))));
end
end

function id_bvs = normalizovat_id_bvs(id_bvs)
if isstring(id_bvs)
    id_bvs = cellstr(id_bvs(:).');
elseif ischar(id_bvs)
    id_bvs = {id_bvs};
elseif ~iscell(id_bvs)
    error('%s', ...
        'Идентификаторы БВС должны быть заданы списком строк.');
end

id_bvs = cellfun(@(znachenie) char(string(znachenie)), ...
    id_bvs, ...
    'UniformOutput', false);
end
