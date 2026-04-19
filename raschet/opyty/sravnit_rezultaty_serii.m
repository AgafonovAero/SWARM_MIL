function tablica_sravneniya = sravnit_rezultaty_serii(rezultaty_opytov)
if nargin < 1 || ~isstruct(rezultaty_opytov) || isempty(rezultaty_opytov)
    error('%s', 'Для сравнения серии требуется непустой список результатов опытов.');
end

if ~isfield(rezultaty_opytov, 'pokazateli')
    error('%s', ...
        'Каждый результат опыта должен содержать поле pokazateli.');
end

tablica_sravneniya = struct2table([rezultaty_opytov.pokazateli]);
tablica_sravneniya = movevars(tablica_sravneniya, ...
    {'id_serii', 'id_varianta', 'id_scenariya', 'nomer_povtora'}, ...
    'Before', 1);
end
