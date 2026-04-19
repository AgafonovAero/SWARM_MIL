function oblast_poleta = proverit_oblast_poleta(oblast_poleta, opisanie_istochnika)
if nargin < 1 || ~isstruct(oblast_poleta)
    error('%s', 'Область полета должна быть задана структурой.');
end

if nargin < 2 || strlength(string(opisanie_istochnika)) == 0
    opisanie_istochnika = 'области полета';
end

imena_granits = {'xmin', 'xmax', 'ymin', 'ymax', 'zmin', 'zmax'};
for nomer_granitsy = 1:numel(imena_granits)
    imya_granitsy = imena_granits{nomer_granitsy};
    if ~isfield(oblast_poleta, imya_granitsy)
        error('%s', sprintf( ...
            'В описании %s отсутствует граница %s.', ...
            opisanie_istochnika, imya_granitsy));
    end

    oblast_poleta.(imya_granitsy) = proverit_chislovuyu_granicu( ...
        oblast_poleta.(imya_granitsy), ...
        imya_granitsy, ...
        opisanie_istochnika);
end

if ~(oblast_poleta.xmin < oblast_poleta.xmax ...
        && oblast_poleta.ymin < oblast_poleta.ymax ...
        && oblast_poleta.zmin < oblast_poleta.zmax)
    error('%s', sprintf( ...
        'Границы %s заданы некорректно: нижняя граница должна быть меньше верхней по каждой оси.', ...
        opisanie_istochnika));
end
end

function znachenie = proverit_chislovuyu_granicu(znachenie, imya_granitsy, opisanie_istochnika)
if ~isnumeric(znachenie) || ~isscalar(znachenie) || ~isfinite(znachenie)
    error('%s', sprintf( ...
        'Граница %s в описании %s должна быть конечным числом.', ...
        imya_granitsy, opisanie_istochnika));
end

znachenie = double(znachenie);
end
