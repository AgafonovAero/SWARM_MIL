function obnovlennye_sostoyaniya = shag_kinematiki_roya(sostoyaniya_bvs, shag_vremeni, oblast_poleta)

if nargin < 1 || ~isstruct(sostoyaniya_bvs)
    error('%s', 'Для шага кинематики роя требуется массив состояний БВС.');
end

if isempty(sostoyaniya_bvs)
    error('%s', 'Массив состояний БВС пустой.');
end

obnovlennye_sostoyaniya = sostoyaniya_bvs;
for nomer_bvs = 1:numel(sostoyaniya_bvs)
    obnovlennye_sostoyaniya(nomer_bvs) = shag_kinematiki_bvs( ...
        sostoyaniya_bvs(nomer_bvs), ...
        shag_vremeni, ...
        oblast_poleta);
end
end
