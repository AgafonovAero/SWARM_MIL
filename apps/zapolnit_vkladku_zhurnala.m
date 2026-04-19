function elementy = zapolnit_vkladku_zhurnala(vkladka)
maket = uigridlayout(vkladka, [2, 1]);
maket.RowHeight = {32, '1x'};
maket.ColumnWidth = {'1x'};
maket.Padding = [10, 10, 10, 10];

knopka_ochistit = uibutton(maket, 'push');
knopka_ochistit.Layout.Row = 1;
knopka_ochistit.Layout.Column = 1;
knopka_ochistit.Text = 'Очистить журнал';

oblast_zhurnala = uitextarea(maket);
oblast_zhurnala.Layout.Row = 2;
oblast_zhurnala.Layout.Column = 1;
oblast_zhurnala.Editable = 'off';
oblast_zhurnala.Value = {'Журнал пульта пуст.'};

elementy = struct();
elementy.maket = maket;
elementy.knopka_ochistit = knopka_ochistit;
elementy.oblast_zhurnala = oblast_zhurnala;
end
