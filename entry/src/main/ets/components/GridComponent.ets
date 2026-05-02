import { QueueService } from '../service/QueueService';

@Component
export struct GridComponent {
  @ObjectLink queue: QueueService;

  aboutToAppear(): void {
    this.queue.startInterval();
  }

  aboutToDisappear(): void {
    this.queue.destroy();
  }

  @Builder
  itemBuilder(item: string) {
    Column() {
      Text(item)
        .fontSize(20)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
      Text(this.queue.getSubtitleText(item))
        .fontSize(8)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor(this.queue.getBgColor(item))
    .borderRadius(40)
    .padding(2)
    .margin({ left: 5, right: 5 })
  }

  build() {
    Grid(this.queue.scroller) {
      LazyForEach(this.queue.datasource, (item: string, index: number) => {
        GridItem() {
          this.itemBuilder(item)
        }
        .height(80)
        .onAppear(() => {
          this.queue.onAppear(index);
        })
        .onClick((_) => {
          this.queue.showMessage(item);
        })
      }, (item: string) => item)
    }
    .cachedCount(5)
    .columnsTemplate('1fr 1fr 1fr')
    .columnsGap(4)
    .rowsGap(4)
    .enableScrollInteraction(true)
    .supportAnimation(true)
    .multiSelectable(false)
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .scrollBar(BarState.On)
    .scrollBarColor(Color.Grey)
    .scrollBarWidth(4)
    .onScrollIndex((start: number, end: number) => {
      this.queue.visibleAreaChanged(start, end);
    })
    .onScrollBarUpdate((index: number, offset: number) => {
      console.info(`Grid onScrollBarUpdate,index :  ${index.toString()},offset ${offset.toString()}`);
      return { totalOffset: (index / 5) * (80 + 10) - offset, totalLength: 80 * 5 + 10 * 4 };
    })
    .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
      console.info(scrollOffset.toString());
      console.info(scrollState.toString());
    })
    .onScrollStart(() => {
      console.info('XXX' + 'Grid onScrollStart');
    })
    .onScrollStop(() => {
      console.info('XXX' + 'Grid onScrollStop');
    })
    .onReachStart(() => {
      console.info('XXX' + 'Grid onReachStart');
    })
    .onReachEnd(() => {
      this.queue.showMessage('Queue is finished.');
      console.info('XXX' + 'Grid onReachEnd');
    })
  }
}