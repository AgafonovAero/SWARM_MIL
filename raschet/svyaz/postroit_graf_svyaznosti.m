function graf_svyaznosti = postroit_graf_svyaznosti(sostoyaniya_bvs, parametry_svyazi, shag_rascheta)

sostoyaniya_bvs = proverit_massiv_sostoyanii(sostoyaniya_bvs);
parametry_svyazi = proverit_parametry_svyazi(parametry_svyazi);
shag_rascheta = proverit_shag_rascheta(shag_rascheta);

[matrica_rasstoyanii_m, id_bvs] = raschet_matricy_rasstoyanii(sostoyaniya_bvs);
chislo_bvs = numel(sostoyaniya_bvs);

matrica_smeznosti = false(chislo_bvs, chislo_bvs);
matrica_otnosheniya_signal_shum = zeros(chislo_bvs, chislo_bvs);
matrica_propusknoy_sposobnosti_bit_s = zeros(chislo_bvs, chislo_bvs);
matrica_poleznosti_linii = zeros(chislo_bvs, chislo_bvs);

for nomer_stroki = 1:chislo_bvs
    for nomer_stolbca = nomer_stroki + 1:chislo_bvs
        otsenka_linii = otsenit_liniyu_svyazi( ...
            sostoyaniya_bvs(nomer_stroki), ...
            sostoyaniya_bvs(nomer_stolbca), ...
            parametry_svyazi, ...
            shag_rascheta);

        matrica_smeznosti(nomer_stroki, nomer_stolbca) = otsenka_linii.est_liniya;
        matrica_smeznosti(nomer_stolbca, nomer_stroki) = otsenka_linii.est_liniya;

        matrica_otnosheniya_signal_shum(nomer_stroki, nomer_stolbca) = ...
            otsenka_linii.otnoshenie_signal_shum;
        matrica_otnosheniya_signal_shum(nomer_stolbca, nomer_stroki) = ...
            otsenka_linii.otnoshenie_signal_shum;

        matrica_propusknoy_sposobnosti_bit_s(nomer_stroki, nomer_stolbca) = ...
            otsenka_linii.propusknaya_sposobnost_bit_s;
        matrica_propusknoy_sposobnosti_bit_s(nomer_stolbca, nomer_stroki) = ...
            otsenka_linii.propusknaya_sposobnost_bit_s;

        matrica_poleznosti_linii(nomer_stroki, nomer_stolbca) = ...
            otsenka_linii.poleznost_linii;
        matrica_poleznosti_linii(nomer_stolbca, nomer_stroki) = ...
            otsenka_linii.poleznost_linii;
    end
end

stepeni_bvs = sum(matrica_smeznosti, 2);
chislo_linii = nnz(triu(matrica_smeznosti, 1));
srednyaya_stepen = mean(stepeni_bvs);
svyazen = opredelit_svyaznost_grafa(matrica_smeznosti);

proverit_graf( ...
    matrica_smeznosti, ...
    matrica_rasstoyanii_m, ...
    matrica_otnosheniya_signal_shum, ...
    matrica_propusknoy_sposobnosti_bit_s, ...
    matrica_poleznosti_linii, ...
    stepeni_bvs);

graf_svyaznosti = struct();
graf_svyaznosti.id_bvs = id_bvs;
graf_svyaznosti.matrica_smeznosti = matrica_smeznosti;
graf_svyaznosti.matrica_rasstoyanii_m = matrica_rasstoyanii_m;
graf_svyaznosti.matrica_otnosheniya_signal_shum = matrica_otnosheniya_signal_shum;
graf_svyaznosti.matrica_propusknoy_sposobnosti_bit_s = ...
    matrica_propusknoy_sposobnosti_bit_s;
graf_svyaznosti.matrica_poleznosti_linii = matrica_poleznosti_linii;
graf_svyaznosti.stepeni_bvs = double(stepeni_bvs);
graf_svyaznosti.chislo_linii = double(chislo_linii);
graf_svyaznosti.srednyaya_stepen = double(srednyaya_stepen);
graf_svyaznosti.svyazen = logical(svyazen);
end

function sostoyaniya_bvs = proverit_massiv_sostoyanii(sostoyaniya_bvs)
if nargin < 1 || ~isstruct(sostoyaniya_bvs) || isempty(sostoyaniya_bvs)
    error('%s', 'Для построения графа связности требуется непустой массив состояний БВС.');
end

for nomer_bvs = 1:numel(sostoyaniya_bvs)
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs(sostoyaniya_bvs(nomer_bvs));
end
end

function shag_rascheta = proverit_shag_rascheta(shag_rascheta)
if ~isnumeric(shag_rascheta) || ~isscalar(shag_rascheta) || ~isfinite(shag_rascheta)
    error('%s', 'Шаг расчета графа связности должен быть конечным числом.');
end

shag_rascheta = double(shag_rascheta);
if shag_rascheta <= 0
    error('%s', 'Шаг расчета графа связности должен быть положительным.');
end
end

function proverit_graf(matrica_smeznosti, matrica_rasstoyanii_m, matrica_otnosheniya_signal_shum, matrica_propusknoy_sposobnosti_bit_s, matrica_poleznosti_linii, stepeni_bvs)

if ~islogical(matrica_smeznosti)
    error('%s', 'Матрица смежности должна быть логической.');
end

if ~isequaln(matrica_smeznosti, matrica_smeznosti.')
    error('%s', 'Матрица смежности должна быть симметричной.');
end

if any(diag(matrica_smeznosti))
    error('%s', 'На диагонали матрицы смежности связи не допускаются.');
end

if ~all(isfinite(matrica_rasstoyanii_m(:))) ...
        || ~all(isfinite(matrica_otnosheniya_signal_shum(:))) ...
        || ~all(isfinite(matrica_propusknoy_sposobnosti_bit_s(:))) ...
        || ~all(isfinite(matrica_poleznosti_linii(:)))
    error('%s', 'Числовые матрицы графа связности должны содержать только конечные значения.');
end

if ~isequaln(stepeni_bvs, sum(matrica_smeznosti, 2))
    error('%s', 'Степени БВС не соответствуют матрице смежности.');
end
end

function svyazen = opredelit_svyaznost_grafa(matrica_smeznosti)
chislo_bvs = size(matrica_smeznosti, 1);
if chislo_bvs <= 1
    svyazen = true;
    return
end

poseshchen = false(chislo_bvs, 1);
ochered = zeros(chislo_bvs, 1);
nachalo_ocheredi = 1;
konets_ocheredi = 1;
ochered(1) = 1;
poseshchen(1) = true;

while nachalo_ocheredi <= konets_ocheredi
    tekushchaya_vershina = ochered(nachalo_ocheredi);
    nachalo_ocheredi = nachalo_ocheredi + 1;
    sosedi = find(matrica_smeznosti(tekushchaya_vershina, :));

    for nomer_soseda = 1:numel(sosedi)
        sosed = sosedi(nomer_soseda);
        if ~poseshchen(sosed)
            konets_ocheredi = konets_ocheredi + 1;
            ochered(konets_ocheredi) = sosed;
            poseshchen(sosed) = true;
        end
    end
end

svyazen = all(poseshchen);
end
