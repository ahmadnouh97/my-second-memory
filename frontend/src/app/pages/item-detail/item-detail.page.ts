import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NgIf, NgFor, DatePipe } from '@angular/common';
import { ActivatedRoute, Router } from '@angular/router';
import {
  IonBackButton,
  IonButton,
  IonButtons,
  IonChip,
  IonContent,
  IonHeader,
  IonIcon,
  IonInput,
  IonItem,
  IonLabel,
  IonSpinner,
  IonTextarea,
  IonTitle,
  IonToolbar,
  AlertController,
  ToastController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { openOutline, create, trash, checkmark, close, add } from 'ionicons/icons';
import { Browser } from '@capacitor/browser';
import { ApiService } from '../../services/api.service';
import { Item } from '../../models/item.model';

@Component({
  selector: 'app-item-detail',
  templateUrl: 'item-detail.page.html',
  standalone: true,
  imports: [
    NgIf, NgFor, DatePipe, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonButtons, IonBackButton,
    IonContent, IonItem, IonLabel, IonInput, IonTextarea,
    IonButton, IonIcon, IonChip, IonSpinner,
  ],
})
export class ItemDetailPage implements OnInit {
  item: Item | null = null;
  isLoading = true;
  isEditing = false;
  isSaving = false;

  editTitle = '';
  editSummary = '';
  editTags: string[] = [];
  newTag = '';

  constructor(
    private api: ApiService,
    private route: ActivatedRoute,
    private router: Router,
    private alertCtrl: AlertController,
    private toastCtrl: ToastController,
  ) {
    addIcons({ openOutline, create, trash, checkmark, close, add });
  }

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (!id) { this.router.navigate(['/home']); return; }

    this.api.getItem(id).subscribe({
      next: (item) => {
        this.item = item;
        this.resetEditFields();
        this.isLoading = false;
      },
      error: () => {
        this.isLoading = false;
        this.router.navigate(['/home']);
      },
    });
  }

  resetEditFields(): void {
    if (!this.item) return;
    this.editTitle = this.item.title;
    this.editSummary = this.item.summary ?? '';
    this.editTags = [...this.item.tags];
  }

  startEdit(): void {
    this.isEditing = true;
  }

  cancelEdit(): void {
    this.resetEditFields();
    this.isEditing = false;
  }

  addTag(): void {
    const tag = this.newTag.trim().toLowerCase().replace(/\s+/g, '-');
    if (tag && !this.editTags.includes(tag)) {
      this.editTags = [...this.editTags, tag];
    }
    this.newTag = '';
  }

  removeTag(tag: string): void {
    this.editTags = this.editTags.filter((t) => t !== tag);
  }

  async saveEdit(): Promise<void> {
    if (!this.item) return;
    this.isSaving = true;

    this.api.updateItem(this.item.id, {
      title: this.editTitle,
      summary: this.editSummary,
      tags: this.editTags,
    }).subscribe({
      next: (updated) => {
        this.item = updated;
        this.isEditing = false;
        this.isSaving = false;
        this.toastCtrl.create({ message: 'Saved!', duration: 1500, color: 'success' })
          .then((t) => t.present());
      },
      error: () => {
        this.isSaving = false;
        this.toastCtrl.create({ message: 'Failed to save', duration: 2000, color: 'danger' })
          .then((t) => t.present());
      },
    });
  }

  async openUrl(): Promise<void> {
    if (!this.item) return;
    await Browser.open({ url: this.item.url });
  }

  async confirmDelete(): Promise<void> {
    const alert = await this.alertCtrl.create({
      header: 'Delete item?',
      message: 'This cannot be undone.',
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Delete',
          role: 'destructive',
          handler: () => {
            this.api.deleteItem(this.item!.id).subscribe({
              next: () => {
                this.router.navigate(['/home'], { replaceUrl: true });
              },
            });
          },
        },
      ],
    });
    await alert.present();
  }
}
