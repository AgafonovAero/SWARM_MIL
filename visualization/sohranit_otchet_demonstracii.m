function papka_otcheta = sohranit_otchet_demonstracii(demonstraciya, dannye_vizualizacii, koren_proekta)
if nargin < 3
    error('%s', [ ...
        'Для сохранения отчета требуются данные демонстрации, данные ' ...
        'визуализации и корень проекта.' ...
        ]);
end

if ~isstruct(demonstraciya) || ~isstruct(dannye_vizualizacii)
    error('%s', ...
        'Отчет демонстрации можно сохранять только по корректным структурам.');
end

papka_bazovaya = fullfile(koren_proekta, 'opyty', 'rezultaty', 'demonstracii');
if ~isfolder(papka_bazovaya)
    mkdir(papka_bazovaya);
end

metka_vremeni = char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'));
bezopasnyi_id = regexprep( ...
    char(string(demonstraciya.id_scenariya)), ...
    '[^A-Za-zА-Яа-я0-9_\\-]', '_');
papka_otcheta = fullfile(papka_bazovaya, [bezopasnyi_id '_' metka_vremeni]);
mkdir(papka_otcheta);

put_k_summary = fullfile(papka_otcheta, 'summary.md');
put_k_metrics = fullfile(papka_otcheta, 'metrics.json');
put_k_mat = fullfile(papka_otcheta, 'result.mat');

zapisat_summary_md(put_k_summary, demonstraciya);
zapisat_metrics_json(put_k_metrics, demonstraciya, dannye_vizualizacii);
save(put_k_mat, 'demonstraciya', 'dannye_vizualizacii', '-v7');
end

function zapisat_summary_md(put_k_failu, demonstraciya)
stroki = {
    '# Краткий отчет демонстрационного опыта'
    ''
    '## Сценарий'
    ''
    ['- идентификатор сценария: `' demonstraciya.id_scenariya '`;']
    ['- число БВС: ' num2str(demonstraciya.kinematika.chislo_bvs) ';']
    ['- длительность опыта: ' num2str(demonstraciya.kinematika.vremya_modelirovaniya) ' с;']
    ['- шаг моделирования: ' num2str(demonstraciya.kinematika.shag_modelirovaniya) ' с.']
    ''
    '## Основные показатели'
    ''
    ['- доля времени связного роя: ' num2str(demonstraciya.svyaznost.dolya_vremeni_svyaznogo_roya, '%.4f') ';']
    ['- среднее число звеньев: ' num2str(demonstraciya.zvenya.srednee_chislo_zvenev, '%.4f') ';']
    ['- доля доставленных сообщений: ' num2str(demonstraciya.peredacha.dolya_dostavlennyh, '%.4f') ';']
    ['- среднее число пересылок: ' num2str(demonstraciya.peredacha.srednee_chislo_peresylok, '%.4f') '.']
    ''
    '## Ограничения опыта'
    ''
    '- демонстрация строится по уже рассчитанным данным;'
    '- визуализация не изменяет движение БВС;'
    '- управление, обучение, распределение ресурсов и модели Simulink не реализованы.'
    };

zapisat_utf8_fail(put_k_failu, stroki);
end

function zapisat_metrics_json(put_k_failu, demonstraciya, dannye_vizualizacii)
stroki = {
    '{'
    ['  "id_scenariya": "' podgotovit_json_stroku(demonstraciya.id_scenariya) '",']
    ['  "chislo_bvs": ' num2str(demonstraciya.kinematika.chislo_bvs) ',']
    ['  "vremya_modelirovaniya": ' num2str(demonstraciya.kinematika.vremya_modelirovaniya, '%.6f') ',']
    ['  "shag_modelirovaniya": ' num2str(demonstraciya.kinematika.shag_modelirovaniya, '%.6f') ',']
    ['  "dolya_vremeni_svyaznogo_roya": ' num2str(demonstraciya.svyaznost.dolya_vremeni_svyaznogo_roya, '%.6f') ',']
    ['  "srednee_chislo_zvenev": ' num2str(demonstraciya.zvenya.srednee_chislo_zvenev, '%.6f') ',']
    ['  "dolya_dostavlennyh": ' num2str(demonstraciya.peredacha.dolya_dostavlennyh, '%.6f') ',']
    ['  "srednyaya_zaderzhka_dostavki_s": ' num2str(demonstraciya.peredacha.srednyaya_zaderzhka_dostavki_s, '%.6f') ',']
    ['  "srednee_chislo_peresylok": ' num2str(demonstraciya.peredacha.srednee_chislo_peresylok, '%.6f') ',']
    ['  "chislo_kadrov": ' num2str(numel(dannye_vizualizacii.kadry))]
    '}'
    };

zapisat_utf8_fail(put_k_failu, stroki);
end

function stroka = podgotovit_json_stroku(znachenie)
stroka = char(string(znachenie));
stroka = strrep(stroka, '\', '\\');
stroka = strrep(stroka, '"', '\"');
end

function zapisat_utf8_fail(put_k_failu, stroki)
identifikator = fopen(put_k_failu, 'w', 'n', 'UTF-8');
if identifikator == -1
    error('%s', sprintf( ...
        'Не удалось открыть файл для записи: %s', ...
        put_k_failu));
end

ochistka = onCleanup(@() fclose(identifikator));
fprintf(identifikator, '%s\n', stroki{:});
clear ochistka
end
