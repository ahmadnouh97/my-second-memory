import { Component, Input } from '@angular/core';
import { Router } from '@angular/router';
import { NgIf, NgFor } from '@angular/common';
import {
  IonCard,
  IonCardContent,
  IonChip,
  IonLabel,
  IonIcon,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { openOutline } from 'ionicons/icons';
import { Item } from '../../models/item.model';

@Component({
  selector: 'app-chat-item-widget',
  templateUrl: 'chat-item-widget.component.html',
  standalone: true,
  imports: [NgIf, NgFor, IonCard, IonCardContent, IonChip, IonLabel, IonIcon],
})
export class ChatItemWidgetComponent {
  @Input({ required: true }) item!: Item;

  constructor(private router: Router) {
    addIcons({ openOutline });
  }

  navigate(): void {
    this.router.navigate(['/item', this.item.id]);
  }
}
