import { Component, OnInit } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { NgFor, NgIf } from '@angular/common';
import {
  IonContent,
  IonFab,
  IonFabButton,
  IonHeader,
  IonIcon,
  IonInfiniteScroll,
  IonInfiniteScrollContent,
  IonRefresher,
  IonRefresherContent,
  IonSearchbar,
  IonSpinner,
  IonTitle,
  IonToolbar,
  IonButtons,
  IonButton,
  ToastController,
  AlertController,
} from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';
import { add, chatbubbleEllipses } from 'ionicons/icons';
import { debounceTime, distinctUntilChanged, Subject, switchMap, of } from 'rxjs';
import { ApiService } from '../../services/api.service';
import { Item } from '../../models/item.model';
import { ItemCardComponent } from '../../components/item-card/item-card.component';
import { FilterBarComponent, FilterState } from '../../components/filter-bar/filter-bar.component';

@Component({
  selector: 'app-home',
  templateUrl: 'home.page.html',
  standalone: true,
  imports: [
    NgFor, NgIf, FormsModule,
    IonHeader, IonToolbar, IonTitle, IonContent, IonSearchbar,
    IonFab, IonFabButton, IonIcon, IonSpinner,
    IonInfiniteScroll, IonInfiniteScrollContent,
    IonRefresher, IonRefresherContent,
    IonButtons, IonButton,
    RouterLink,
    ItemCardComponent, FilterBarComponent,
  ],
})
export class HomePage implements OnInit {
  items: Item[] = [];
  allTags: string[] = [];
  searchQuery = '';
  isLoading = false;
  currentPage = 1;
  hasMore = true;
  activeFilters: FilterState = { tags: [] };

  private searchSubject = new Subject<string>();

  constructor(
    private api: ApiService,
    private router: Router,
    private toastCtrl: ToastController,
    private alertCtrl: AlertController,
  ) {
    addIcons({ add, chatbubbleEllipses });
  }

  ngOnInit(): void {
    this.loadItems(true);
    this.searchSubject.pipe(
      debounceTime(400),
      distinctUntilChanged(),
    ).subscribe((q) => {
      if (q.trim()) {
        this.runSearch(q);
      } else {
        this.loadItems(true);
      }
    });
  }

  onSearchInput(event: CustomEvent): void {
    this.searchQuery = event.detail.value ?? '';
    this.searchSubject.next(this.searchQuery);
  }

  onFilterChanged(filters: FilterState): void {
    this.activeFilters = filters;
    if (this.searchQuery.trim()) {
      this.runSearch(this.searchQuery);
    } else {
      this.loadItems(true);
    }
  }

  private async runSearch(q: string): Promise<void> {
    this.isLoading = true;
    this.api.searchItems(q, {
      tags: this.activeFilters.tags.length ? this.activeFilters.tags : undefined,
      content_type: this.activeFilters.content_type,
    }).subscribe({
      next: (results) => {
        this.items = results;
        this.hasMore = false;
        this.isLoading = false;
      },
      error: () => {
        this.isLoading = false;
      },
    });
  }

  async loadItems(reset = false, event?: CustomEvent): Promise<void> {
    if (reset) {
      this.currentPage = 1;
      this.hasMore = true;
    }

    this.isLoading = reset;

    this.api.listItems({
      page: this.currentPage,
      limit: 20,
      tags: this.activeFilters.tags.length ? this.activeFilters.tags : undefined,
      content_type: this.activeFilters.content_type,
      date_from: this.activeFilters.date_from,
      date_to: this.activeFilters.date_to,
    }).subscribe({
      next: (response) => {
        if (reset) {
          this.items = response.items;
          this.collectTags(response.items);
        } else {
          this.items = [...this.items, ...response.items];
          this.collectTags(response.items);
        }
        this.hasMore = this.items.length < response.total;
        this.currentPage++;
        this.isLoading = false;
        if (event) {
          (event.target as HTMLIonInfiniteScrollElement).complete();
          (event.target as HTMLIonRefresherElement).complete?.();
        }
      },
      error: () => {
        this.isLoading = false;
        if (event) {
          (event.target as HTMLIonInfiniteScrollElement).complete?.();
          (event.target as HTMLIonRefresherElement).complete?.();
        }
      },
    });
  }

  private collectTags(items: Item[]): void {
    const tagSet = new Set(this.allTags);
    items.forEach((i) => i.tags.forEach((t) => tagSet.add(t)));
    this.allTags = Array.from(tagSet).sort();
  }

  loadMore(event: CustomEvent): void {
    if (!this.hasMore) {
      (event.target as HTMLIonInfiniteScrollElement).complete();
      return;
    }
    this.loadItems(false, event);
  }

  refresh(event: CustomEvent): void {
    this.searchQuery = '';
    this.loadItems(true, event);
  }

  async onDeleteItem(id: string): Promise<void> {
    const alert = await this.alertCtrl.create({
      header: 'Delete item?',
      message: 'This cannot be undone.',
      buttons: [
        { text: 'Cancel', role: 'cancel' },
        {
          text: 'Delete',
          role: 'destructive',
          handler: () => {
            this.api.deleteItem(id).subscribe({
              next: async () => {
                this.items = this.items.filter((i) => i.id !== id);
                const toast = await this.toastCtrl.create({
                  message: 'Item deleted',
                  duration: 2000,
                  color: 'medium',
                });
                toast.present();
              },
            });
          },
        },
      ],
    });
    await alert.present();
  }

  goToChat(): void {
    this.router.navigate(['/chat']);
  }
}
