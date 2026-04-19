function soobshchenie(tekst, uroven)
if nargin < 1
    error('Не передан текст сообщения.');
end

if nargin < 2
    uroven = '';
end

tekst = char(string(tekst));
uroven = lower(char(string(uroven)));

switch uroven
    case 'oshibka'
        fprintf(2, 'Ошибка: %s\n', tekst);
    case 'preduprezhdenie'
        fprintf('Предупреждение: %s\n', tekst);
    otherwise
        fprintf('%s\n', tekst);
end
end
