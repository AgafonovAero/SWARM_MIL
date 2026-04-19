function rezultat = vypolnit_raschet_iz_simulink_stenda(koren_proekta, parametry)
if nargin < 1 || strlength(string(koren_proekta)) == 0
    error('%s', ...
        'Для запуска расчета из Simulink-стенда требуется корень проекта.');
end

if nargin < 2 || isempty(parametry)
    parametry = podgotovit_parametry_simulink_stenda(koren_proekta);
end

parametry = proverit_parametry_stenda(parametry);
sostoyanie = sozdat_sostoyanie_pulta(koren_proekta);
put_k_scenariyu = nayti_put_k_scenariyu( ...
    sostoyanie.spisok_scenariev, ...
    parametry.id_scenariya);

sostoyanie.tekushchii_put_k_scenariyu = put_k_scenariyu;
sostoyanie.tekushchii_scenarii = zagruzit_scenarii(put_k_scenariyu);
sostoyanie.parametry_svyazi = parametry.parametry_svyazi;
sostoyanie.parametry_zvenev = parametry.parametry_zvenev;
sostoyanie.parametry_peredachi = parametry.parametry_peredachi;

[~, demonstraciya, dannye_vizualizacii] = vypolnit_raschet_iz_pulta(sostoyanie);

rezultat = struct();
rezultat.id_scenariya = demonstraciya.id_scenariya;
rezultat.parametry = parametry;
rezultat.scenarii = demonstraciya.scenarii;
rezultat.kinematika = demonstraciya.kinematika;
rezultat.svyaznost = demonstraciya.svyaznost;
rezultat.zvenya = demonstraciya.zvenya;
rezultat.peredacha = demonstraciya.peredacha;
rezultat.vizualizaciya = dannye_vizualizacii;
rezultat.primechanie = [ ...
    'Расчет из Simulink-представления выполняется средствами ' ...
    'существующего MATLAB-ядра проекта.' ...
    ];
end

function parametry = proverit_parametry_stenda(parametry)
obyazatelnye_polya = { ...
    'id_scenariya'
    'parametry_svyazi'
    'parametry_zvenev'
    'parametry_peredachi'
    'vremya_modelirovaniya'
    'shag_modelirovaniya'
    'primechanie'
    };

if ~isstruct(parametry)
    error('%s', ...
        'Параметры Simulink-стенда должны быть переданы структурой.');
end

for nomer_polya = 1:numel(obyazatelnye_polya)
    imya_polya = obyazatelnye_polya{nomer_polya};
    if ~isfield(parametry, imya_polya)
        error('%s', sprintf( ...
            'В параметрах Simulink-стенда отсутствует поле %s.', ...
            imya_polya));
    end
end

parametry.id_scenariya = char(string(parametry.id_scenariya));
parametry.parametry_svyazi = proverit_parametry_svyazi(parametry.parametry_svyazi);
parametry.parametry_zvenev = proverit_parametry_zvenev(parametry.parametry_zvenev);
parametry.parametry_peredachi = ...
    proverit_parametry_peredachi(parametry.parametry_peredachi);

if ~isscalar(parametry.vremya_modelirovaniya) ...
        || ~isnumeric(parametry.vremya_modelirovaniya) ...
        || ~isfinite(parametry.vremya_modelirovaniya) ...
        || parametry.vremya_modelirovaniya <= 0
    error('%s', ...
        'Время моделирования в параметрах Simulink-стенда задано неверно.');
end

if ~isscalar(parametry.shag_modelirovaniya) ...
        || ~isnumeric(parametry.shag_modelirovaniya) ...
        || ~isfinite(parametry.shag_modelirovaniya) ...
        || parametry.shag_modelirovaniya <= 0
    error('%s', ...
        'Шаг моделирования в параметрах Simulink-стенда задан неверно.');
end
end

function put_k_scenariyu = nayti_put_k_scenariyu(spisok_putei, identifikator)
put_k_scenariyu = '';

for nomer_puti = 1:numel(spisok_putei)
    [~, imya_scenariya] = fileparts(spisok_putei{nomer_puti});
    if strcmp(imya_scenariya, identifikator)
        put_k_scenariyu = spisok_putei{nomer_puti};
        return
    end
end

error('%s', sprintf( ...
    'Сценарий `%s` отсутствует в списке базовых сценариев.', ...
    identifikator));
end
