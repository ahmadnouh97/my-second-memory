import { Component, EventEmitter, Input, Output } from '@angular/core';
import { Router } from '@angular/router';
import { NgIf, NgFor, DatePipe, SlicePipe } from '@angular/common';
import {
  IonCard,
  IonCardContent,
  IonCardHeader,
  IonCardTitle,
  IonChip,
  IonIcon,
  IonLabel,
  IonButton,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { logoYoutube, logoInstagram, document, link, trash } from 'ionicons/icons';
import { Item } from '../../models/item.model';

@Component({
  selector: 'app-item-card',
  templateUrl: 'item-card.component.html',
  standalone: true,
  imports: [
    NgIf, NgFor, DatePipe, SlicePipe,
    IonCard, IonCardContent, IonCardHeader, IonCardTitle,
    IonChip, IonIcon, IonLabel, IonButton,
  ],
})
export class ItemCardComponent {
  @Input({ required: true }) item!: Item;
  @Input() showDelete = false;
  @Output() deleted = new EventEmitter<string>();

  constructor(private router: Router) {
    addIcons({ logoYoutube, logoInstagram, document, link, trash });
  }

  navigate(): void {
    this.router.navigate(['/item', this.item.id]);
  }

  onDelete(event: Event): void {
    event.stopPropagation();
    this.deleted.emit(this.item.id);
  }

  get typeIcon(): string {
    const icons: Record<string, string> = {
      youtube: 'logo-youtube',
      instagram: 'logo-instagram',
      article: 'document',
      link: 'link',
    };
    return icons[this.item.content_type] ?? 'link';
  }

  get typeColor(): string {
    const colors: Record<string, string> = {
      youtube: 'danger',
      instagram: 'tertiary',
      article: 'primary',
      link: 'medium',
    };
    return colors[this.item.content_type] ?? 'medium';
  }
}
