//
//  ViewController.m
//  printDemo
//
//  Created by  夜晚太黑 on 16/4/26.
//  Copyright © 2016年  夜晚太黑. All rights reserved.
//

#import "ViewController.h"
#import "HHBluetoothPrinterManager.h"

@interface ViewController ()<HHBluetoothPrinterManagerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    HHBluetoothPrinterManager *manager;
    //选中的设备
    CBPeripheral *selectedPeripheral;
    NSMutableArray *dataArray1;
    NSMutableArray *sendDataArray;
    UITableView *table;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    sendDataArray= [[NSMutableArray alloc]init];
    manager = [HHBluetoothPrinterManager sharedManager];
    manager.delegate = self;
    dataArray1 = [[NSMutableArray alloc] init];//初始化
    [NSTimer scheduledTimerWithTimeInterval:(float)0.02 target:self selector:@selector(sendDataTimer:) userInfo:nil repeats:YES];
    UIButton *scan= [[UIButton alloc]initWithFrame:CGRectMake(20, 20, 100, 40)];
    scan.backgroundColor = [UIColor redColor];
    [scan setTitle:@"开始扫描" forState:UIControlStateNormal];
    [scan addTarget:self action:@selector(scanStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scan];
    UIButton *stop= [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+20, 20, 100, 40)];
    stop.backgroundColor = [UIColor redColor];
    [stop setTitle:@"停止扫描" forState:UIControlStateNormal];
    [stop addTarget:self action:@selector(scanStop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stop];
    UIButton *dayin= [[UIButton alloc]initWithFrame:CGRectMake(20, 80, 100, 40)];
    dayin.backgroundColor = [UIColor redColor];
    [dayin setTitle:@"开始打印" forState:UIControlStateNormal];
    [dayin addTarget:self action:@selector(dayinStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:dayin];
    UIButton *duankai= [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2+20, 80, 100, 40)];
    duankai.backgroundColor = [UIColor redColor];
    [duankai setTitle:@"断开打印机" forState:UIControlStateNormal];
    [duankai addTarget:self action:@selector(duankaiStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:duankai];
    UIButton *erweima= [[UIButton alloc]initWithFrame:CGRectMake(20, 140, 100, 40)];
    erweima.backgroundColor = [UIColor redColor];
    [erweima setTitle:@"二维码" forState:UIControlStateNormal];
    [erweima addTarget:self action:@selector(erweimaStart) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:erweima];

    table = [[UITableView alloc]initWithFrame:CGRectMake(0, 190, self.view.frame.size.width, self.view.frame.size.height-100)];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    // Do any additional setup after loading the view, typically from a nib.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray1.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CBPeripheral *peripheral = [dataArray1 objectAtIndex:indexPath.row];
    cell.textLabel.text = peripheral.name;
    
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedPeripheral = [dataArray1 objectAtIndex:indexPath.row];
    [manager connectPeripheral:[dataArray1 objectAtIndex:indexPath.row]];

}

- (void)duankaiStart{//断开
    [manager cancelScan];
    [manager duankai:selectedPeripheral];
}

- (void)scanStop{//停止扫描
    [manager cancelScan];
}
- (void)scanStart{//开始扫描
    [manager scanPeripherals];
}
- (void) didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"did Connect Peripheral");
    
    NSLog(@"ok");
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral {//扫描到的设备
    [dataArray1 addObject:peripheral];
    [table reloadData];
    
}
- (void) sendDataTimer:(NSTimer *)timer {//发送打印数据
    //NSLog(@"send data timer");
    
    if ([sendDataArray count] > 0) {
        NSData* cmdData;
        
        cmdData = [sendDataArray objectAtIndex:0];
        [manager startPrint:cmdData];
        
        [sendDataArray removeObjectAtIndex:0];
    }
}
- (void)jinga{
    unsigned char* cData = (unsigned char *)calloc(100, sizeof(unsigned char));
    NSData* sendData = nil;
    //选中中文指令集
    cData[0] = 0x1b;
    cData[1] = 0x74;
    cData[2] = 15;
    sendData = [NSData dataWithBytes:cData length:3];
    
    free(cData);
    [sendDataArray addObject:sendData];
    
}
- (void)jingb{
    unsigned char* cData = (unsigned char *)calloc(100, sizeof(unsigned char));
    NSData* sendData = nil;
    //选中中文指令集
    cData[0] = 0x1c;
    cData[1] = 0x26;
    sendData = [NSData dataWithBytes:cData length:2];
    free(cData);
    [sendDataArray addObject:sendData];
    
}

- (void)dayinStart{//打印
    [self printerInit];
    [self jingb];
    [self jinga];
    
    [self printerWithFormat:Align_Center CharZoom:Char_Zoom_2 Content:@"班友点餐宝\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"订单编号：OD2016217115200045\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"门店：湖东店\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"电话：0512-62552546\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"地址：湖东邻里中心Z125室\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"操作员：admin\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"订单信息：\n"];
        [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"订单属性：外卖\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:[NSString stringWithFormat: @"订单来源：%@\n",@"门店"]];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"商品详情：\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"名字      数量       金额\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Zoom_2 Content:[NSString stringWithFormat: @"实付金额：%@\n",@"100.00"]];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"--------------------------------\n\n"];
    NSDateFormatter *dataFormat = [[NSDateFormatter alloc] init];
    [dataFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* displayTime = nil;
    NSDate *date = [NSDate date];
    displayTime = [dataFormat stringFromDate:date];
    [self printerWithFormat:Align_Center CharZoom:Char_Normal Content:@"感谢您的惠顾，欢迎下次光临\n"];
    [self printerWithFormat:Align_Center CharZoom:Char_Normal Content:[NSString stringWithFormat: @"打印时间：   %@\n",displayTime]];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"\n"];
    [self printerWithFormat:Align_Left CharZoom:Char_Normal Content:@"\n"];
    [self printerInit];
}
- (void)erweimaStart{//二维码
    UIImage * printimage = [self createQRForString:@"二维码支付"];
    [self png2GrayscaleImage:printimage];

}
- (UIImage *) png2GrayscaleImage:(UIImage *) oriImage {
    //const int ALPHA = 0;
    const int RED = 1;
    const int GREEN = 2;
    const int BLUE = 3;
    
    int width = oriImage.size.width ;//imageRect.size.width;
    int height =oriImage.size.height;
    int imgSize = width * height;
    int x_origin = 0;
    int y_to = height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(imgSize * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, imgSize * sizeof(uint32_t));
    
    NSInteger nWidthByteSize = (width+7)/8;
    
    NSInteger nBinaryImgDataSize = nWidthByteSize * y_to;
    Byte *binaryImgData = (Byte *)malloc(nBinaryImgDataSize);
    
    memset(binaryImgData, 0, nBinaryImgDataSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width , height), [oriImage CGImage]);
    
    
    Byte controlData[8];
    controlData[0] = 0x1d;
    controlData[1] = 0x76;//'v';
    controlData[2] = 0x30;
    controlData[3] = 0;
    controlData[4] = nWidthByteSize & 0xff;
    controlData[5] = (nWidthByteSize>>8) & 0xff;
    controlData[6] = y_to & 0xff;
    controlData[7] = (y_to>>8) & 0xff;
    NSData *printData = [[NSData alloc] initWithBytes:controlData length:8];
    [self printData:printData];
    
    for(int y = 0; y < y_to; y++) {
        for(int x = x_origin; x < width ; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11 * rgbaPixel[BLUE];
            
            // set the pixels to gray
            /*
             rgbaPixel[RED] = gray;
             rgbaPixel[GREEN] = gray;
             rgbaPixel[BLUE] = gray;
             */
            if (gray > 228) {
                rgbaPixel[RED] = 255;
                rgbaPixel[GREEN] = 255;
                rgbaPixel[BLUE] = 255;
                
            }else{
                rgbaPixel[RED] = 0;
                rgbaPixel[GREEN] = 0;
                rgbaPixel[BLUE] = 0;
                binaryImgData[(y*width+x)/8] |= (0x80>>(x%8));
            }
        }
        
        
    }
    
    printData = [[NSData alloc] initWithBytes:binaryImgData length:nBinaryImgDataSize];
    [self printData:printData];
    
    memset(controlData, '\n', 8);
    printData = [[NSData alloc] initWithBytes:controlData length:3];
    [self printData:printData];
    
    
    return 0;
}
- (void) printData:(NSData *)dataPrinted {
    NSLog(@"print data:%lu", (unsigned long)[dataPrinted length]);
//    aa++;
#define MAX_CHARACTERISTIC_VALUE_SIZE 20
    NSData  *data	= nil;
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    
    NSLog(@"print data:%@", dataPrinted);
    
    
    strLength = [dataPrinted length];
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }
        else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        
        NSLog(@"print:%lu,%lu,%lu,%lu", (unsigned long)strLength,(unsigned long)cellCount, (unsigned long)cellMin, (unsigned long)cellLen);
        NSRange rang = NSMakeRange(cellMin, cellLen);
        
        data = [dataPrinted subdataWithRange:rang];
        NSLog(@"print:%@", data);
//        if (aa>3) {
        
//        }else{
            [sendDataArray addObject:data];
//        }
        //        [manager startPrint:data];
    }
}

- (UIImage *)createQRForString:(NSString *)qrString {
    
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    [filter setDefaults];
    
    NSData *data = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:data
              forKey:@"inputMessage"];
    
    CIImage *outputImage = [filter outputImage];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                       fromRect:[outputImage extent]];
    
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:0.1
                                   orientation:UIImageOrientationUp];
    
    // 不失真的放大
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:10.0];
    
    // 缩放到固定的宽度(高度与宽度一致)
    UIImage * endImage = [self scaleWithFixedWidth:400 image:resized];
    
    CGImageRelease(cgImage);
    
    return endImage;
    
}
- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
    UIImage *resized = nil;
    CGFloat width = image.size.width * rate;
    CGFloat height = image.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}
- (UIImage *)scaleWithFixedWidth:(CGFloat)width image:(UIImage *)image
{
    float newHeight = image.size.height * (width / image.size.width);
    CGSize size = CGSizeMake(width, newHeight);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}

- (void) printerWithFormat:(Align_Type_e)eAlignType CharZoom:(Char_Zoom_Num_e)eCharZoomNum Content:(NSString *)printContent{
    NSData  *data	= nil;
    NSUInteger strLength;
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    Byte caPrintFmt[500];
    
    /*初始化命令：ESC @ 即0x1b,0x40*/
    //caPrintFmt[0] = 0x1b;
    //caPrintFmt[1] = 0x40;
    
    /*字符设置命令：ESC ! n即0x1b,0x21,n*/
    caPrintFmt[0] = 0x1d;
    caPrintFmt[1] = 0x21;
    caPrintFmt[2] = (eCharZoomNum<<4) | eCharZoomNum;
    caPrintFmt[3] = 0x1b;
    caPrintFmt[4] = 0x61;
    caPrintFmt[5] = eAlignType;
    NSData *printData = [printContent dataUsingEncoding: enc];
    Byte *printByte = (Byte *)[printData bytes];
    
    strLength = [printData length];
    if (strLength < 1) {
        return;
    }
    
    for (int  i = 0; i<strLength; i++) {
        caPrintFmt[6+i] = *(printByte+i);
    }
    
    data = [NSData dataWithBytes:caPrintFmt length:6+strLength];
    
    [self printLongData:data];
}


- (void) printLongData:(NSData *)printContent{
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    
    strLength = [printContent length];
    if (strLength < 1) {
        return;
    }
    
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }
        else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        
        NSLog(@"print:%d,%d,%d,%d", strLength,cellCount, cellMin, cellLen);
        NSRange rang = NSMakeRange(cellMin, cellLen);
        NSData *subData = [printContent subdataWithRange:rang];
        
        NSLog(@"print:%@", subData);
        [sendDataArray addObject:subData];
    }
}
- (void) printerInit{
    NSData *printFormat;
    Byte caPrintFmt[20];
    
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x40;
    printFormat = [NSData dataWithBytes:caPrintFmt length:2];
    NSLog(@"format:%@", printFormat);
    
    [sendDataArray addObject:printFormat];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
