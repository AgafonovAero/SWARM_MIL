function [parametry_svyazi, parametry_zvenev, parametry_peredachi] = proverit_parametry_pulta(parametry_svyazi, parametry_zvenev, parametry_peredachi)
if nargin < 3
    error('%s', [ ...
        'Для проверки параметров пульта требуются параметры связи, ' ...
        'звеньев и передачи.' ...
        ]);
end

parametry_svyazi = proverit_parametry_svyazi(parametry_svyazi);
parametry_zvenev = proverit_parametry_zvenev(parametry_zvenev);
parametry_peredachi = proverit_parametry_peredachi(parametry_peredachi);

if parametry_zvenev.maksimalnyi_razmer_zvena < ...
        parametry_zvenev.minimalnyi_razmer_zvena
    error('%s', ...
        'Максимальный размер звена не может быть меньше минимального.');
end

if parametry_peredachi.maksimalnyi_razmer_ocheredi <= 0
    error('%s', 'Максимальный размер очереди должен быть положительным.');
end

if parametry_peredachi.maksimalnoe_chislo_peresylok <= 0
    error('%s', 'Максимальное число пересылок должно быть положительным.');
end

if parametry_peredachi.vremya_zhizni_soobshcheniya_s <= 0
    error('%s', 'Время жизни сообщения должно быть положительным.');
end
end
