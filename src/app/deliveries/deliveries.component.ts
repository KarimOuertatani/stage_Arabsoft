import { Component, OnInit, ViewChild, HostListener, Inject } from '@angular/core';
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
import { NgChartsModule } from 'ng2-charts';
import { ChartConfiguration, ChartData } from 'chart.js';
import { ApiService } from '../services/api.service';
import { Livraison } from '../models/livraison.model';
import { Utilisateur } from '../models/utilisateur.model';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { MtxAlertModule } from '@ng-matero/extensions/alert';
import { MatSelectModule } from '@angular/material/select';

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
    NgChartsModule,
    RouterLink,
    RouterLinkActive,
    MtxAlertModule
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
        this.livraisons = livraisons;
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
    /*const dialogRef = this.dialog.open(DeliveryDialogComponent, {
      width: '400px',
      data: { ...livraison }
    });

   dialogRef.afterClosed().subscribe(result => {
      if (result && result.adresseLivraison && result.statut) {
        this.isLoading = true;
        this.apiService.updateLivraison(id, result).subscribe({
          next: () => {
            this.loadDeliveries();
          },
          error: (err: any) => {
            console.error('Erreur lors de la mise à jour de la livraison:', err);
            this.errorMessage = 'Failed to update delivery. Please try again.';
            this.isLoading = false;
          }
        });
      }
    });*/
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