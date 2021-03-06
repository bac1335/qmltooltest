﻿#ifndef BAIDUFACEMANAGER_H
#define BAIDUFACEMANAGER_H
#include <QObject>

class BaiduFaceManager : public QObject{
    Q_OBJECT
public:
    explicit BaiduFaceManager(QObject* parent = nullptr);
    void startFace();
    Q_INVOKABLE QString start(QString imgpath);
    Q_INVOKABLE QString startFromStr(const QImage* img);

    Q_INVOKABLE bool addImgToServer(const QImage* img);

public slots:
    void onSendServerImg(QImage* img);

private:
    void init();

private:
    bool        m_bIsFaceTakenOk = false;
    QString     m_id;
    QString     m_appKey;
    QString     m_secretKey;

};

#endif // BAIDUFACEMANAGER_H
