import { Routes } from '@angular/router';

export const routes: Routes = [
  {
    path: '',
    redirectTo: 'home',
    pathMatch: 'full',
  },
  {
    path: 'home',
    loadComponent: () =>
      import('./pages/home/home.page').then((m) => m.HomePage),
  },
  {
    path: 'add-item',
    loadComponent: () =>
      import('./pages/add-item/add-item.page').then((m) => m.AddItemPage),
  },
  {
    path: 'item/:id',
    loadComponent: () =>
      import('./pages/item-detail/item-detail.page').then((m) => m.ItemDetailPage),
  },
  {
    path: 'chat',
    loadComponent: () =>
      import('./pages/chat/chat.page').then((m) => m.ChatPage),
  },
];
