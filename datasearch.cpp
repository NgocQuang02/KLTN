// datasearch.cpp
#include "datasearch.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

DataSearch::DataSearch(QObject *parent) : QObject(parent)
{
    QFile file("/home/quang/Downloads/DoAn/data_merge.csv");

    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream in(&file);
        while (!in.atEnd())
        {
            QString line = in.readLine();
            m_lines.append(line);
        }
        file.close();
    }
    else
    {
        qDebug() << "Failed to open file!" << file.errorString();
    }
}

void DataSearch::search(const QString &keyword)
{
    QStringList result;
    for (const QString &line : m_lines)
    {
        if (line.contains(keyword.trimmed(), Qt::CaseInsensitive))
        {
            result.append(line);
        }
    }
    emit searchResult(result);
}
