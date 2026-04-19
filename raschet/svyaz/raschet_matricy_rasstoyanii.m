function [matrica_rasstoyanii_m, id_bvs] = raschet_matricy_rasstoyanii(sostoyaniya_bvs)
sostoyaniya_bvs = proverit_massiv_sostoyanii_bvs(sostoyaniya_bvs);

chislo_bvs = numel(sostoyaniya_bvs);
matrica_rasstoyanii_m = zeros(chislo_bvs, chislo_bvs);
id_bvs = cell(1, chislo_bvs);

for nomer_bvs = 1:chislo_bvs
    id_bvs{nomer_bvs} = sostoyaniya_bvs(nomer_bvs).id_bvs;
end

for nomer_stroki = 1:chislo_bvs
    for nomer_stolbca = nomer_stroki + 1:chislo_bvs
        raznost = sostoyaniya_bvs(nomer_stroki).polozhenie ...
            - sostoyaniya_bvs(nomer_stolbca).polozhenie;
        rasstoyanie = norm(raznost, 2);
        matrica_rasstoyanii_m(nomer_stroki, nomer_stolbca) = rasstoyanie;
        matrica_rasstoyanii_m(nomer_stolbca, nomer_stroki) = rasstoyanie;
    end
end

if any(diag(matrica_rasstoyanii_m) ~= 0)
    error('%s', 'На диагонали матрицы расстояний должны стоять нули.');
end

if ~isequaln(matrica_rasstoyanii_m, matrica_rasstoyanii_m.')
    error('%s', 'Матрица расстояний должна быть симметричной.');
end
end

function sostoyaniya_bvs = proverit_massiv_sostoyanii_bvs(sostoyaniya_bvs)
if nargin < 1 || ~isstruct(sostoyaniya_bvs) || isempty(sostoyaniya_bvs)
    error('%s', 'Для расчета матрицы расстояний требуется непустой массив состояний БВС.');
end

for nomer_bvs = 1:numel(sostoyaniya_bvs)
    sostoyaniya_bvs(nomer_bvs) = proverit_sostoyanie_bvs(sostoyaniya_bvs(nomer_bvs));

    if ~isfield(sostoyaniya_bvs(nomer_bvs), 'polozhenie')
        error('%s', sprintf( ...
            'У состояния БВС номер %d отсутствует поле polozhenie.', ...
            nomer_bvs));
    end
end
end
