import { Component, OnInit, ViewChild, HostListener, Inject, ChangeDetectorRef } from '@angular/core';
import { MatTableModule } from '@angular/material/table';
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatSidenav, MatSidenavModule } from '@angular/material/sidenav';
import { MatListModule } from '@angular/material/list';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialogModule, MatDialog, MatDialogRef, MAT_DIALOG_DATA } from '@angular/material/dialog';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Livraison } from '../models/livraison.model';
import { Utilisateur } from '../models/utilisateur.model';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import * as L from 'leaflet';
import { HttpClient } from '@angular/common/http';
import { SidebarComponent } from "../sidebar/sidebar.component";

@Component({
  selector: 'app-deliveries',
  templateUrl: './deliveries.component.html',
  styleUrls: ['./deliveries.component.scss'],
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatTableModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatSidenavModule,
    MatListModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule,
    SidebarComponent
]
})
export class DeliveriesComponent implements OnInit {
  @ViewChild('sidenav') sidenav!: MatSidenav;

  livraisons: Livraison[] = [];
  livraisonColumns = ['id', 'adresseLivraison', 'statut', 'actions'];
  isShowAlert: boolean = true;
  isDarkTheme: boolean = false;
  isLoading: boolean = true;
  errorMessage: string | null = null;
  currentUser: Utilisateur | null = null;
  isSidenavCollapsed: boolean = false;
  windowWidth: number = window.innerWidth;

  deliveryChartData: ChartData<'pie'> = {
    labels: ['En Attente', 'En Cours', 'Livrée', 'Annulée'],
    datasets: [
      {
        data: [0, 0, 0, 0],
        backgroundColor: ['#f59e0b', '#2563eb', '#14b8a6', '#dc2626'],
        borderColor: '#ffffff',
        borderWidth: 2
      }
    ]
  };

  chartOptions: ChartConfiguration['options'] = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: true,
        position: 'right',
        labels: { font: { family: 'Inter, Roboto, sans-serif', size: 14 } }
      },
      tooltip: {
        enabled: true,
        backgroundColor: '#1f2a44',
        titleFont: { family: 'Inter, Roboto, sans-serif' },
        bodyFont: { family: 'Inter, Roboto, sans-serif' }
      }
    }
  };

  constructor(private apiService: ApiService, private router: Router, private dialog: MatDialog) {}

  @HostListener('window:resize', ['$event'])
  onResize(event: Event): void {
    this.windowWidth = window.innerWidth;
    this.isSidenavCollapsed = this.windowWidth <= 599;
  }

  ngOnInit() {
    this.isShowAlert = localStorage.getItem('showAlert') !== 'false';
    this.isDarkTheme = localStorage.getItem('theme') === 'dark';
    this.isSidenavCollapsed = this.windowWidth <= 599;

    const token = localStorage.getItem('jwt_token');
    if (!token) {
      this.router.navigate(['/login']);
      return;
    }

    this.apiService.getCurrentUser().subscribe({
      next: (user) => {
        this.currentUser = user;
        this.loadDeliveries();
      },
      error: (err) => {
        console.error('Error fetching current user:', err);
        this.router.navigate(['/login']);
      }
    });

    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  private loadDeliveries() {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.getLivraisons().subscribe({
      next: (livraisons) => {
        this.livraisons = livraisons.filter(l => l.id !== undefined); // Ensure no undefined IDs
        this.updateChartData();
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Erreur lors de la récupération des livraisons:', err);
        this.errorMessage = 'Failed to load deliveries. Please try again.';
        this.isLoading = false;
      }
    });
  }

  private updateChartData() {
    const counts = {
      EN_ATTENTE: 0,
      EN_COURS: 0,
      LIVREE: 0,
      ANNULEE: 0
    };
    this.livraisons.forEach(livraison => counts[livraison.statut]++);
    this.deliveryChartData.datasets[0].data = [counts.EN_ATTENTE, counts.EN_COURS, counts.LIVREE, counts.ANNULEE];
  }

  openEditDialog(livraison: Livraison) {
    if (livraison.id === undefined) {
      this.errorMessage = 'Cannot edit delivery: ID is undefined';
      return;
    }
    const dialogRef = this.dialog.open(DeliveryDialogComponent, {
      width: '400px',
      data: { ...livraison }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result && result.adresseLivraison && result.statut && livraison.id !== undefined) {
        this.isLoading = true;
        this.apiService.updateLivraison(livraison.id, result).subscribe({
          next: () => {
            this.loadDeliveries();
          },
          error: (err: any) => {
            console.error('Erreur lors de la mise à jour de la livraison:', err);
            this.errorMessage = 'Failed to update updatedelivery. Please try again.';
            this.isLoading = false;
          }
        });
      }
    });
  }

  openDeleteDialog(id: number, adresse: string) {
    const dialogRef = this.dialog.open(ConfirmDialogComponent, {
      width: '350px',
      data: { message: `Are you sure you want to delete delivery to ${adresse}?` }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.deleteDelivery(id);
      }
    });
  }

  openMapDialog(adresse: string) {
    this.dialog.open(MapDialogComponent, {
      width: '600px',
      height: '500px',
      data: { adresse }
    });
  }

  dispatchDelivery(id: number) {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.updateLivraisonStatus(id, 'EN_COURS').subscribe({
      next: (updatedLivraison) => {
        console.log('Delivery dispatched successfully:', updatedLivraison);
        this.loadDeliveries();
      },
      error: (err) => {
        console.error('Error dispatching delivery:', err);
        let errorMsg = 'Failed to dispatch delivery. Please try again.';
        if (err.status === 404) {
          errorMsg = 'Delivery not found. It may have been deleted.';
        } else if (err.status === 400) {
          errorMsg = 'Invalid status update. Please check the delivery status.';
        }
        this.errorMessage = errorMsg;
        this.isLoading = false;
      }
    });
  }

  deleteDelivery(id: number) {
    this.isLoading = true;
    this.errorMessage = null;

    this.apiService.deleteLivraison(id).subscribe({
      next: () => {
        this.loadDeliveries();
      },
      error: (err: any) => {
        console.error('Erreur lors de la suppression de la livraison:', err);
        this.errorMessage = 'Failed to delete delivery. Please try again.';
        this.isLoading = false;
      }
    });
  }

  onAlertDismiss(): void {
    this.isShowAlert = false;
    localStorage.setItem('showAlert', 'false');
  }

  toggleTheme(): void {
    this.isDarkTheme = !this.isDarkTheme;
    localStorage.setItem('theme', this.isDarkTheme ? 'dark' : 'light');
    document.body.classList.toggle('dark-theme', this.isDarkTheme);
  }

  toggleSidenav(): void {
    this.isSidenavCollapsed = !this.isSidenavCollapsed;
    this.sidenav.toggle();
  }

  logout(): void {
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('theme');
    localStorage.removeItem('showAlert');
    this.router.navigate(['/login']);
  }

  retry(): void {
    this.loadDeliveries();
  }
}

@Component({
  selector: 'app-delivery-dialog',
  template: `
    <h1 mat-dialog-title>Edit Delivery</h1>
    <div mat-dialog-content>
      <mat-form-field appearance="outline">
        <mat-label>Address</mat-label>
        <input matInput [(ngModel)]="data.adresseLivraison" required>
        <mat-error *ngIf="!data.adresseLivraison">Address is required</mat-error>
      </mat-form-field>
      <mat-form-field appearance="outline">
        <mat-label>Status</mat-label>
        <mat-select [(ngModel)]="data.statut" required>
          <mat-option value="EN_ATTENTE">En Attente</mat-option>
          <mat-option value="EN_COURS">En Cours</mat-option>
          <mat-option value="LIVREE">Livrée</mat-option>
          <mat-option value="ANNULEE">Annulée</mat-option>
        </mat-select>
        <mat-error *ngIf="!data.statut">Status is required</mat-error>
      </mat-form-field>
    </div>
    <div mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close()">Cancel</button>
      <button mat-raised-button color="primary" (click)="dialogRef.close(data)" [disabled]="!data.adresseLivraison || !data.statut">Save</button>
    </div>
  `,
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    MatDialogModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatSelectModule
  ]
})
export class DeliveryDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<DeliveryDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: Livraison
  ) {}
}

@Component({
  selector: 'app-confirm-dialog',
  template: `
    <h2 mat-dialog-title>Confirm Deletion</h2>
    <mat-dialog-content>{{ data.message }}</mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close(false)">Cancel</button>
      <button mat-button color="warn" (click)="dialogRef.close(true)">Delete</button>
    </mat-dialog-actions>
  `,
  standalone: true,
  imports: [MatDialogModule, MatButtonModule]
})
export class ConfirmDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ConfirmDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { message: string }
  ) {}
}

@Component({
  selector: 'app-map-dialog',
  template: `
    <h1 mat-dialog-title>Delivery Location</h1>
    <div mat-dialog-content>
      <div id="map" style="height: 400px; width: 100%;"></div>
    </div>
    <div mat-dialog-actions align="end">
      <button mat-button (click)="dialogRef.close()">Close</button>
    </div>
  `,
  styles: [
    `
      #map {
        height: 400px;
        width: 100%;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      }
    `
  ],
  standalone: true,
  imports: [MatDialogModule, MatButtonModule]
})
export class MapDialogComponent implements OnInit {
  private map: L.Map | undefined;

  constructor(
    public dialogRef: MatDialogRef<MapDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public data: { adresse: string },
    private http: HttpClient,
    private cdr: ChangeDetectorRef
  ) {}

  ngOnInit() {
    setTimeout(() => this.initializeMap(), 0); // Ensure map initializes after DOM render
  }

  private initializeMap() {
    // Initialize map
    this.map = L.map('map', {
      center: [0, 0],
      zoom: 2,
      zoomControl: true,
      attributionControl: true
    });

    // Add OpenStreetMap tile layer
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map);

    // Invalidate size to fix rendering issues
    setTimeout(() => {
      if (this.map) {
        this.map.invalidateSize();
      }
    }, 100);

    // Geocode the address
    this.http
      .get<any>(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(this.data.adresse)}`, {
        headers: { 'User-Agent': 'SmartInventory/1.0' } // Required by Nominatim policy
      })
      .subscribe({
        next: (response: string | any[]) => {
          if (response && response.length > 0) {
            const { lat, lon, display_name } = response[0];
            if (this.map) {
              this.map.setView([lat, lon], 15);
              L.marker([lat, lon])
                .addTo(this.map)
                .bindPopup(`<b>Delivery Location</b><br>${display_name}`)
                .openPopup();
            }
          } else {
            if (this.map) {
              this.map.setView([0, 0], 2);
              L.popup()
                .setLatLng([0, 0])
                .setContent('Address not found')
                .openOn(this.map);
            }
          }
          this.cdr.detectChanges();
        },
        error: (err: any) => {
          console.error('Error geocoding address:', err);
          if (this.map) {
            this.map.setView([0, 0], 2);
            L.popup()
              .setLatLng([0, 0])
              .setContent('Error loading map')
              .openOn(this.map);
          }
          this.cdr.detectChanges();
        }
      });
  }

  ngOnDestroy() {
    if (this.map) {
      this.map.remove();
    }
  }
}