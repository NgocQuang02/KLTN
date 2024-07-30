// datasearch.h
#ifndef DATASEARCH_H
#define DATASEARCH_H

#include <QObject>
#include <QStringList>

class DataSearch : public QObject
{
    Q_OBJECT
public:
    explicit DataSearch(QObject *parent = nullptr);

    Q_INVOKABLE void search(const QString &keyword);

signals:
    void searchResult(const QStringList &result);

private:
    QStringList m_lines;
};

#endif
