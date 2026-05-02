import { HorizontalInfiniteComponent } from '../components/HorizontalInfiniteComponent';
import { VerticalListComponent } from '../components/VerticalListComponent';
import { GridComponent } from '../components/GridComponent';
import { QueueService } from '../service/QueueService';
import { SimpleDialog } from '../components/SimpleDialog';
import { SplashPage } from 'feature_splash';

@Entry
@Component
struct Index {
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack();
  @State queue: QueueService = QueueService.getInstance();

  aboutToAppear(): void {
    this.queue.dialogController = new CustomDialogController({
      builder: SimpleDialog({
        content: this.queue.message,
        close: () => {
          this.queue.startInterval();
        }
      }),
      autoCancel: true,
      onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
        if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
          dismissDialogAction.dismiss();
        }
        if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
          dismissDialogAction.dismiss();
        }
      },
      alignment: DialogAlignment.Center,
      offset: { dx: 2, dy: -10 },
      gridCount: 4,
      showInSubWindow: true,
      isModal: true,
      customStyle: false,
      cornerRadius: 10,
      width: '60%',
      height: '70%',
      focusable: true
    })
    this.pageStack.pushPathByName('SplashPage', null);
  }

  @Builder
  PageMap(name: string) {
    if (name === 'SplashPage') {
      SplashPage();
    } else if (name) {
      this.HomePage();
    } else if (name === 'VerticalList') {
      this.VerticalListPage();
    } else if (name === 'HorizontalScroll') {
      this.HorizontalScrollPage();
    } else if (name === 'GridView') {
      this.GridPage();
    }
  }

  build() {
    Navigation(this.pageStack) {

    }
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }

  @Builder
  HomePage() {
    NavDestination() {
      Column({ space: 15 }) {
        Text('Queue Center')
          .fontSize(22)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)

        Button('Vertical Board').onClick(() => this.pageStack.pushPath({ name: 'VerticalList' })).width('80%')
        Button('Infinite Scroll').onClick(() => this.pageStack.pushPath({ name: 'HorizontalScroll' })).width('80%')
        Button('Grid Overview').onClick(() => this.pageStack.pushPath({ name: 'GridView' })).width('80%')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.Black)
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .backgroundColor(Color.Black)
  }

  @Builder
  VerticalListPage() {
    NavDestination() {
      VerticalListComponent({ queue: this.queue })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .backgroundColor(Color.Black)
  }

  @Builder
  GridPage() {
    NavDestination() {
      GridComponent({ queue: this.queue })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .backgroundColor(Color.Black)
  }

  @Builder
  HorizontalScrollPage() {
    NavDestination() {
      HorizontalInfiniteComponent({ queue: this.queue })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .backgroundColor(Color.Black);
  }
}