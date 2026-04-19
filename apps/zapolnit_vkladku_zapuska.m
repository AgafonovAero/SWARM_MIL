function elementy = zapolnit_vkladku_zapuska(vkladka)
maket = uigridlayout(vkladka, [4, 3]);
maket.RowHeight = {32, 32, 32, '1x'};
maket.ColumnWidth = {'1x', '1x', '1x'};
maket.Padding = [10, 10, 10, 10];

knopka_zapuska = uibutton(maket, 'push');
knopka_zapuska.Layout.Row = 1;
knopka_zapuska.Layout.Column = 1;
knopka_zapuska.Text = 'Запустить расчет';

knopka_otkryt_demonstraciyu = uibutton(maket, 'push');
knopka_otkryt_demonstraciyu.Layout.Row = 1;
knopka_otkryt_demonstraciyu.Layout.Column = 2;
knopka_otkryt_demonstraciyu.Text = 'Открыть демонстрацию';

knopka_sohranit_otchet = uibutton(maket, 'push');
knopka_sohranit_otchet.Layout.Row = 1;
knopka_sohranit_otchet.Layout.Column = 3;
knopka_sohranit_otchet.Text = 'Сохранить отчет';

indikator_sostoyaniya = uilabel(maket);
indikator_sostoyaniya.Layout.Row = 2;
indikator_sostoyaniya.Layout.Column = [1, 3];
indikator_sostoyaniya.Text = 'Состояние: расчет еще не запускался.';
indikator_sostoyaniya.FontWeight = 'bold';

tablica_itogov = uitable(maket);
tablica_itogov.Layout.Row = [3, 4];
tablica_itogov.Layout.Column = [1, 3];
tablica_itogov.ColumnName = {'Показатель', 'Значение'};
tablica_itogov.Data = {'Пока нет данных', ''};

elementy = struct();
elementy.maket = maket;
elementy.knopka_zapuska = knopka_zapuska;
elementy.knopka_otkryt_demonstraciyu = knopka_otkryt_demonstraciyu;
elementy.knopka_sohranit_otchet = knopka_sohranit_otchet;
elementy.indikator_sostoyaniya = indikator_sostoyaniya;
elementy.tablica_itogov = tablica_itogov;
end
